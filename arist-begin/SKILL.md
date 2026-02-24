---
name: arist-begin
description: Use when user input contains `arist-begin` or `arist-begin -q` and needs Arist global development rules; enable Qiuchuang company-specific dynamic-query and Docker packaging constraints only in `-q` mode.
---

# arist-begin

## 触发与生效范围
- 当用户输入包含 `arist-begin` 时，立即启用本技能。
- 启用后，本技能规则对当前任务全程生效，直到用户明确要求停止。

## 模式开关
- `arist-begin`：仅启用本文件中的全局开发规则。
- `arist-begin -q`：在全局开发规则基础上，额外启用“秋创公司级特殊规则”。
- 未出现 `-q` 时，不启用任何秋创公司级特殊规则。

## 全局开发规则
1. 问候规则
- 每次执行完 Shell 命令后，下一条回复开头必须是「大哥！」。
- 每次完成一个用户任务后，回复开头必须是「大哥！」。

2. 代码注释
- 所有新增或修改代码中的注释必须使用中文。

3. 变量命名
- 新增变量与函数参数使用驼峰式命名（camelCase）。

4. 修改安全性
- 任何修改都不能影响已有功能。
- 每次变更必须提供回归验证思路，优先覆盖受影响路径。

## 编码前强制门禁
1. 在编写任何代码之前，先描述实现方案并等待用户批准。
2. 如果需求不明确，先提出澄清问题，得到确认后再写代码。
3. 如果任务预计需要修改超过 3 个文件，先停止编码并拆分为更小任务，再逐步执行。

## TDD 强制流程
每个代码修改都必须遵循以下顺序：
1. 先写测试。
2. 运行测试并确认失败（RED）。
3. 编写最小实现让测试通过（GREEN）。
4. 重构并再次运行测试（REFACTOR）。

## Bug 修复规则
- 发现 bug 时，先写一个可以稳定复现该 bug 的测试。
- 仅在复现测试失败后开始修复。
- 修复后持续运行测试，直到复现测试与相关回归测试全部通过。

## 完成任务规则（用户说「已完成」时）
按顺序执行：
1. 清理调试日志（例如 `console.log`、`Logger.LogInformation` 等调试输出）。
2. 执行构建检查与必要测试。
3. 提交并推送代码。

## 联动规则（与 arist-end）
- 当用户输入「已完成」时，优先提示并切换使用 `$arist-end` 执行标准收尾流程。
- 若当前目录不是 git 仓库，先明确告知无法执行提交/推送，再按用户要求继续非 git 收尾动作。
- 若用户明确要求“不要提交或推送”，联动时仅执行清理与验证步骤，不执行 `git commit` 和 `git push`。

## 秋创公司级特殊规则（仅 `-q` 模式启用）
1. 动态查询规则（DynamicQueryInput / Gridify）
- 在 ABP 应用服务查询场景中，优先使用 `DynamicQueryInput` + `IGridifyQuery` 模式。
- 默认分页上限按公司规范控制（常规默认 `MaxResultCount=1000`），并根据业务设置查询复杂度限制。
- 涉及筛选表达式时，遵循 Gridify 语法（`=`, `!=`, `>`, `<`, `,`, `|`, 括号）并处理特殊字符转义。
- 设计查询时同时考虑：排序字段白名单、Mapper 映射、性能（索引/结果量限制/必要缓存）。

2. Docker 打包规则（linux/amd64）
- 构建镜像必须显式指定 `--platform linux/amd64`。
- 在 Apple Silicon 环境优先使用 `docker buildx build --platform linux/amd64 ...`。
- `docker-compose.yml` 中必须声明目标平台为 `linux/amd64`。
- 构建完成后执行镜像架构校验（如 `docker inspect` 或 `docker manifest inspect`）。

## 输出与汇报要求
- 完成关键步骤后，简要汇报已执行动作、结果与下一步。
- 任何命令失败时，先给出错误原因，再给出修复动作。

## 纠错自学习规则
- 每次用户纠正后，必须在本技能文件追加一条新规则，防止同类问题再次发生。
- 追加位置：本文件的“纠错追加规则”章节。

## 纠错追加规则
- 暂无。
