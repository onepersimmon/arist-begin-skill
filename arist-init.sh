#!/bin/bash
# arist-init.sh - 多模型自动配置脚本
# 用法: ./arist-init.sh
# 功能: 检测系统中安装的大模型（Gemini/Claude/Codex），写入全局开发规则，安装依赖 skills
# 幂等安全：已存在的配置和 skill 会按需更新或跳过

set -e

# 获取脚本所在目录（模板文件相对路径基准）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

echo "🔧 arist-init: 多模型自动配置开始..."
echo ""

# ============================================================
# 第一步：检测已安装的大模型
# ============================================================
DETECTED_MODELS=()

if [ -d "$HOME/.gemini" ]; then
  DETECTED_MODELS+=("gemini")
  echo "✅ 检测到 Gemini（~/.gemini/）"
fi

if [ -d "$HOME/.claude" ]; then
  DETECTED_MODELS+=("claude")
  echo "✅ 检测到 Claude（~/.claude/）"
fi

if [ -d "$HOME/.codex" ]; then
  DETECTED_MODELS+=("codex")
  echo "✅ 检测到 Codex（~/.codex/）"
fi

if [ ${#DETECTED_MODELS[@]} -eq 0 ]; then
  echo "❌ 未检测到任何已安装的大模型（.gemini / .claude / .codex），请先安装至少一个 AI 工具"
  exit 1
fi

echo ""
echo "📋 检测到 ${#DETECTED_MODELS[@]} 个大模型: ${DETECTED_MODELS[*]}"
echo ""

# ============================================================
# 第二步：为每个模型写入全局规则
# ============================================================

# 获取全局规则模板内容
GLOBAL_RULES="$(cat "$TEMPLATES_DIR/global-rules.md")"

write_global_config() {
  local modelName="$1"
  local configFile="$2"
  local headerFile="$3"
  local skillsDir="$4"

  echo "📝 配置 $modelName 全局规则..."

  # 读取模型特定头部
  local headerContent="$(cat "$headerFile")"

  # 替换占位符
  headerContent="${headerContent//__SKILLS_DIR__/$skillsDir}"

  # 拼接头部 + 全局规则
  local fullContent="${headerContent}${GLOBAL_RULES}"

  # 写入配置文件（备份旧文件）
  if [ -f "$configFile" ]; then
    cp "$configFile" "${configFile}.bak"
    echo "  📦 已备份旧配置到 ${configFile}.bak"
  fi

  echo "$fullContent" > "$configFile"
  echo "  ✅ 已写入 $configFile"
}

for model in "${DETECTED_MODELS[@]}"; do
  case "$model" in
    gemini)
      write_global_config "Gemini" \
        "$HOME/.gemini/GEMINI.md" \
        "$TEMPLATES_DIR/gemini-header.md" \
        "$HOME/.gemini/skills"
      ;;
    claude)
      write_global_config "Claude" \
        "$HOME/.claude/CLAUDE.md" \
        "$TEMPLATES_DIR/claude-header.md" \
        "$HOME/.claude/skills"
      ;;
    codex)
      write_global_config "Codex" \
        "$HOME/.codex/AGENTS.md" \
        "$TEMPLATES_DIR/codex-header.md" \
        "$HOME/.codex/skills"
      ;;
  esac
done

echo ""

# ============================================================
# 第三步：安装依赖 skills 到每个模型
# ============================================================

clone_if_missing() {
  local skillsDir="$1"
  local name="$2"
  local url="$3"

  if [ -d "$skillsDir/$name" ]; then
    echo "  ⏭️  $name 已存在，跳过"
  else
    echo "  📦 安装 $name ..."
    git clone "$url" "$skillsDir/$name" --quiet
    echo "  ✅ $name 完成"
  fi
}

# qiusoft 特殊处理：用本地目录或 GitHub 仓库
install_qiusoft() {
  local skillsDir="$1"
  local qiusoftDir="$skillsDir/qiusoft"

  if [ -d "$qiusoftDir" ]; then
    echo "  ⏭️  qiusoft 已存在，跳过"
  else
    echo "  📦 安装 qiusoft ..."
    # 优先从 GitHub 克隆
    if git clone "https://github.com/onepersimmon/qiusoft.git" "$qiusoftDir" --quiet 2>/dev/null; then
      echo "  ✅ qiusoft 完成（从 GitHub）"
    else
      # 如果 GitHub 不可用，从本地复制
      local localQiusoft="$SCRIPT_DIR/../qiusoft"
      if [ -d "$localQiusoft" ]; then
        cp -r "$localQiusoft" "$qiusoftDir"
        echo "  ✅ qiusoft 完成（从本地）"
      else
        echo "  ⚠️  qiusoft 安装失败：GitHub 和本地均不可用"
      fi
    fi
  fi
}

# 定义依赖 skills 列表
# anthropics-skills: skill-creator, frontend-design, document-skills(docx/xlsx/pdf/pptx)
# simonwong-agent-skills: code-simplifier
# ralph-loop: Gemini CLI 扩展
# superpowers: 元技能

SKILL_REPOS=(
  "anthropics-skills|https://github.com/anthropics/skills.git"
  "simonwong-agent-skills|https://github.com/simonwong/agent-skills.git"
  "ralph-loop|https://github.com/gemini-cli-extensions/ralph.git"
  "superpowers|https://github.com/obra/superpowers.git"
)

for model in "${DETECTED_MODELS[@]}"; do
  local_skills_dir=""
  case "$model" in
    gemini) local_skills_dir="$HOME/.gemini/skills" ;;
    claude) local_skills_dir="$HOME/.claude/skills" ;;
    codex)  local_skills_dir="$HOME/.codex/skills" ;;
  esac

  mkdir -p "$local_skills_dir"
  echo "🔌 为 $model 安装依赖 skills（$local_skills_dir）..."

  for repo_entry in "${SKILL_REPOS[@]}"; do
    IFS='|' read -r name url <<< "$repo_entry"
    clone_if_missing "$local_skills_dir" "$name" "$url"
  done

  # 安装 arist-begin-skill（本技能包自身）
  clone_if_missing "$local_skills_dir" "arist-begin-skill" "https://github.com/onepersimmon/arist-begin-skill.git"

  # 安装 qiusoft
  install_qiusoft "$local_skills_dir"

  echo ""
done

# ============================================================
# 第四步：汇报结果
# ============================================================
echo "🎉 多模型自动配置完成！"
echo ""
echo "📊 配置汇总："
for model in "${DETECTED_MODELS[@]}"; do
  case "$model" in
    gemini) echo "  ✅ Gemini  → ~/.gemini/GEMINI.md + ~/.gemini/skills/" ;;
    claude) echo "  ✅ Claude  → ~/.claude/CLAUDE.md + ~/.claude/skills/" ;;
    codex)  echo "  ✅ Codex   → ~/.codex/AGENTS.md + ~/.codex/skills/" ;;
  esac
done
echo ""
echo "📦 已安装的 skills："
echo "  ✅ anthropics-skills    (skill-creator, frontend-design, document-skills)"
echo "  ✅ simonwong-agent-skills (code-simplifier)"
echo "  ✅ ralph-loop"
echo "  ✅ superpowers          (元技能)"
echo "  ✅ arist-begin-skill    (开发流程)"
echo "  ✅ qiusoft              (秋创公司专属)"
