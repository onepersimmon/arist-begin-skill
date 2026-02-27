#!/bin/bash
# arist-init.sh - 一次性初始化所有依赖 skills
# 用法: ./arist-init.sh
# 幂等安全：已存在的 skill 会跳过

set -e

echo "🔧 arist-init: 开始安装依赖 skills..."

# 自动检测 AI 工具的 skills 目录
SKILLS_DIR=""
if [ -d "$HOME/.gemini" ]; then
  SKILLS_DIR="$HOME/.gemini/skills"
elif [ -d "$HOME/.claude" ]; then
  SKILLS_DIR="$HOME/.claude/skills"
else
  echo "❌ 未检测到已安装的 AI 工具（.gemini / .claude），请先安装 AI 工具"
  exit 1
fi

mkdir -p "$SKILLS_DIR"
echo "📁 目标目录: $SKILLS_DIR"

# 定义依赖 skills: 目录名 仓库地址
# anthropics-skills 包含: skill-creator, frontend-design, document-skills(docx/xlsx/pdf/pptx)
# simonwong-agent-skills 包含: code-simplifier
# ralph-loop 是 Gemini CLI 扩展
# superpowers 是元技能

clone_if_missing() {
  local name="$1"
  local url="$2"
  if [ -d "$SKILLS_DIR/$name" ]; then
    echo "  ⏭️  $name 已存在，跳过"
  else
    echo "  📦 安装 $name ..."
    git clone "$url" "$SKILLS_DIR/$name" --quiet
    echo "  ✅ $name 完成"
  fi
}

clone_if_missing "anthropics-skills"       "https://github.com/anthropics/skills.git"
clone_if_missing "simonwong-agent-skills"  "https://github.com/simonwong/agent-skills.git"
clone_if_missing "ralph-loop"              "https://github.com/gemini-cli-extensions/ralph.git"
clone_if_missing "superpowers"             "https://github.com/obra/superpowers.git"

echo ""
echo "🎉 初始化完成！已安装的 skills："
echo "  ✅ skill-creator      (anthropics-skills)"
echo "  ✅ document-skills    (anthropics-skills: docx/xlsx/pdf/pptx)"
echo "  ✅ frontend-design    (anthropics-skills)"
echo "  ✅ code-simplifier    (simonwong-agent-skills)"
echo "  ✅ ralph-loop"
echo "  ✅ superpowers（含 find-skill 能力）"
