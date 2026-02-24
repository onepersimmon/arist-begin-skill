---
name: arist-end
description: Use when user input contains `arist-end`, says `已完成`, or requests end-of-task cleanup/build/commit/push workflow in a git repository.
---

# arist-end

## 概述
- 该技能用于任务收尾，按固定顺序执行清理、验证、提交、推送，避免漏项。
- 当用户发出 `已完成`、`arist-end` 或“收尾/提交/推送”指令时，优先使用本技能。

## 联动入口（来自 arist-begin）
- 当上游技能 `arist-begin` 识别到「已完成」时，本技能作为默认承接流程执行。
- 收到联动后先重复确认一次用户意图：是否包含提交与推送。
- 若用户只要求“检查并汇报”，则执行到“变更复核”后停止，不做提交推送。

## 执行前检查
1. 确认当前目录是 git 仓库。
2. 确认用户希望把当前改动提交到远程分支。
3. 如果不是 git 仓库，明确告知并停止提交流程。

## 标准收尾流程
1. 清理调试日志
- 搜索并移除临时调试输出，例如：`console.log`、`print(...)`、`Logger.LogInformation`（仅删除调试用途语句，不影响业务日志）。

2. 构建与测试检查
- 运行项目已有的构建和测试命令。
- 若无统一命令，至少执行与本次修改直接相关的测试。
- 任一步骤失败则停止提交，并先修复。

3. 变更复核
- 用 `git status --short` 和 `git diff --stat` 复核改动范围。
- 确认没有误提交的敏感信息、临时文件和无关变更。

4. 提交与推送
- 执行 `git add -A`。
- 使用清晰提交信息执行 `git commit`。
- 执行 `git push` 到当前跟踪分支。
- 若分支未跟踪远程，先设置上游后再推送。

5. 汇报结果
- 回报清理项、验证命令结果、提交哈希与远程分支信息。
- 回复开头使用「大哥！」。

## 快速命令参考
| 目标 | 建议命令 |
|------|----------|
| 查看仓库状态 | `git status --short --branch` |
| 查看改动规模 | `git diff --stat` |
| 查调试日志 | `rg "console\\.log|Logger\\.LogInformation|print\\("` |
| 提交 | `git add -A && git commit -m "chore: finalize task"` |
| 推送 | `git push` |

## 与现有技能协同
- 若环境存在 `done-hook` 技能，优先调用它完成标准化收尾。
- 若 `done-hook` 不可用，则按本技能“标准收尾流程”手动执行。

## 常见错误
- 只提交不跑测试：容易把破坏性改动推到远程。
- 直接 `git push` 不看状态：可能把无关文件一并提交。
- 清理日志过度：删除了真实业务日志，导致运行排障困难。

## 结果门禁
- 若 `git push` 失败，不得声称“任务已完成”。
- 若构建或测试失败，不得提交失败状态代码。
