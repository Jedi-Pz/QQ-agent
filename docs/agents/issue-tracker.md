# Issue tracker：GitHub

本仓库的 issue 和 spec 都作为 GitHub issue 存放。所有操作使用 `gh` 命令行。

## 用哪个仓库

Issue 存放在 **fork 仓库** `Jedi-Pz/QQ-agent`。

**不要指望裸 `gh` 命令会自动指向 fork。** 当 `origin` 是一个 fork 时，`gh` 会优先选择**上游父仓库**，所以未做配置的 clone 里执行 `gh issue list`，查的是 `K0nd1us/QQ-agent`。以下两点决定了本仓库的目标是 fork：

1. 当前 clone 的本地 git 配置里设了 `remote.origin.gh-resolved=base`，它会覆盖上面那个「优先父仓库」的行为。用 `gh repo view --json nameWithOwner --jq .nameWithOwner` 确认，输出必须是 `Jedi-Pz/QQ-agent`。
2. **全新 clone 没有这项配置。** 克隆后先执行一次 `gh repo set-default Jedi-Pz/QQ-agent`，或者每次调用 `gh` 都显式带上 `--repo Jedi-Pz/QQ-agent`。

`upstream` 指向 `K0nd1us/QQ-agent`，用于拉取原作者的更新。上游也有 issue：只有当你打算把 bug 报告或 spec 回馈给原项目时才去那边提，并且要显式加上 `--repo K0nd1us/QQ-agent`。

## 常用操作

- **新建 issue**：`gh issue create --title "..." --body "..."`。正文有多行时用 heredoc。
- **读取 issue**：`gh issue view <number> --comments`，用 `jq` 过滤评论，同时取出标签。
- **列出 issue**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，配合需要的 `--label` 和 `--state` 过滤。
- **发表评论**：`gh issue comment <number> --body "..."`
- **添加或移除标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭 issue**：`gh issue close <number> --comment "..."`

仓库从 `git remote -v` 推断，但注意上面「用哪个仓库」一节：在 fork 的 clone 里，`gh` 的自动推断会指向**父仓库**而不是 fork。任何写操作之前先核对目标。

## 把 PR 也当作 triage 对象

**PRs as a request surface: no.**（若本仓库把外部 PR 当作功能请求处理，改成 `yes`；`/triage` 会读取这个标记。上一行是给工具读取的固定标记，不要翻译。）

设为 `yes` 之后，PR 与 issue 走同一套标签和状态，改用对应的 `gh pr` 命令：

- **读取 PR**：`gh pr view <number> --comments` 看全貌，`gh pr diff <number>` 看 diff。
- **列出待 triage 的外部 PR**：`gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`，只保留 `authorAssociation` 为 `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR` 或 `NONE` 的条目，去掉 `OWNER`/`MEMBER`/`COLLABORATOR`。
- **评论、打标签、关闭**：`gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub 的 issue 和 PR 共用一套编号，所以单独一个 `#42` 可能是其中任意一种：先用 `gh pr view 42` 解析，失败再退回 `gh issue view 42`。

## 当某个 skill 说「发布到 issue tracker」

新建一个 GitHub issue。

## 当某个 skill 说「取出对应的工单」

执行 `gh issue view <number> --comments`。

## Wayfind 相关操作

供 `/wayfinder` 使用。**地图**是一个 issue，**子工单**也是 issue。

- **地图**：一个打了 `wayfinder:map` 标签的 issue，正文包含 Notes / Decisions-so-far / Fog 三部分。命令是 `gh issue create --label wayfinder:map`。
- **子工单**：通过 GitHub 的 sub-issue 机制挂到地图下（用 `gh api` 调 sub-issues 接口）。如果仓库没开启 sub-issue，就把子工单加进地图正文的任务列表，并在子工单正文顶部写上 `Part of #<地图编号>`。标签为 `wayfinder:<type>`，type 取值 `research`/`prototype`/`grilling`/`task`。一旦被认领，工单指派给负责的开发。
- **阻塞关系**：使用 GitHub 原生的 issue 依赖，这是界面上可见的标准表示。添加依赖的命令是 `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`，其中 `<blocker-db-id>` 是阻塞方的数字**数据库 id**（用 `gh api repos/<owner>/<repo>/issues/<n> --jq .id` 取，不是 `#编号`，也不是 `node_id`）。GitHub 通过 `issue_dependencies_summary.blocked_by` 报告尚未关闭的阻塞数量，这是实时的门槛。如果仓库不支持依赖功能，退回到在子工单正文顶部写一行 `Blocked by: #<n>, #<n>`。当所有阻塞方都关闭时，工单即解除阻塞。
- **前沿查询**：列出地图下所有未关闭的子工单（`gh issue list --state open`，范围限定在该地图的 sub-issue 或任务列表内），剔除存在未关闭阻塞方的（`issue_dependencies_summary.blocked_by > 0`，或 `Blocked by` 行里还有未关闭的 issue），以及已有指派人的。按地图中的顺序取第一个。
- **认领**：`gh issue edit <n> --add-assignee @me`，这是本次会话的第一次写操作。
- **结案**：`gh issue comment <n> --body "<答案>"`，然后 `gh issue close <n>`，最后把上下文指针（要点加链接）追加到地图的 Decisions-so-far 部分。
