# 本机部署记录：QQ Agent 0.4 + NapCat

> 本文件记录本机（Windows）上的实际部署方式与踩坑修复，**不含任何密钥**。
> 密钥与账号令牌都在被 gitignore 的本地文件里。

## 1. 上游同步

- fork：`Jedi-Pz/QQ-agent`（origin）
- 上游：`K0nd1us/QQ-agent`（remote `upstream`）
- 同步方式：`git fetch upstream && git merge upstream/main`
- 上游在 2026-10-24 做了大改版：源码拆到 `0.4/`（原项目基线）与
  `0.5(unfinished)/`（架构重写未完成），并移除了内置 SnowLuma 集成，
  改为「用户自备 OneBot v11 协议端」。本机部署使用 **0.4**（稳定基线）。

## 2. 组件与端口

| 组件 | 位置 | 说明 |
|---|---|---|
| QQ Agent 应用 | `0.4/` | Electron 桌面端；无桌面时 `npm run server` |
| QQ Agent 控制台 | <http://127.0.0.1:3210> | 设置页完成全部配置 |
| NapCat 协议端 | `0.4/napcat/shell/` | 第三方项目（v4.18.19），不随仓库分发 |
| NapCat WebUI | <http://127.0.0.1:6099> | 扫码登录 / 协议端配置；token 见 `0.4/napcat/shell/napcat/config/webui.json` |
| OneBot 正向 WS | `ws://127.0.0.1:3001` | QQ Agent 订阅事件 |
| OneBot HTTP API | `http://127.0.0.1:3000` | QQ Agent 调用发消息等接口 |

OneBot 访问令牌同时写在两处（两边必须一致）：

- `0.4/napcat/shell/napcat/config/onebot11.json`（NapCat 模板，登录后复制为 `onebot11_<QQ号>.json`）
- `0.4/data/config.json` 的 `onebot.accessToken` / `onebot.httpAccessToken`（QQ Agent）

## 3. 安装步骤（本机已执行）

```bash
cd 0.4
npm install
npm run setup:napcat   # 下载官方 NapCat Release，SHA256 校验后解压
```

> 注意：`npm install` 时 npm 11 默认不执行安装脚本，若 Electron 二进制缺失，
> 执行 `node node_modules/electron/install.js`。

### 3.1 NapCat 缺 DLL 的修复（本机踩坑）

直接运行 `node.exe index.js` 会报：

```
[NapCat] [Process] 启动失败: Error: The specified module could not be found.
...\napcat\shell\wrapper.node
```

原因是该发布包的 `wrapper.node` 依赖 `crypto.dll`、`ssl.dll`，但 zip 里没有。
修复：从本机已安装 QQ 的 `versions\<版本>\resources\app\` 复制这两个 DLL 到
`0.4/napcat/shell/`（本机用的是 `9.9.36-53644` 那版）。修复后启动正常。
⚠️ 若执行 `npm run setup:napcat --force` 重装，需要重新复制这两个 DLL。

## 4. 日常启动顺序

1. 双击 `0.4/启动NapCat协议端.bat`（或 `node napcat/shell/index.js`，工作目录 `napcat/shell`）
2. 浏览器打开 <http://127.0.0.1:6099>，输入 WebUI token，用手机 QQ 扫码登录
   - 建议小号；非官方协议有风控/封号风险
   - 首次登录后 NapCat 才会开放 3000/3001 的 OneBot 服务
3. 双击 `0.4/启动QQ机器人.bat`（或 `cd 0.4 && npm start`）
4. 控制台 <http://127.0.0.1:3210> → 设置页：
   - 模型 API：Base URL + Key + 模型（本机预填 DeepSeek 官方 `https://api.deepseek.com/v1`、`deepseek-flash`）
   - OneBot：确认 ws/http 地址与令牌
   - 白名单：从 QQ 拉群列表勾选允许机器人响应的群

## 5. 数据与安全

- 应用数据（聊天存档、记忆、会话、含 Key 的配置）：`0.4/data/`（已 gitignore）
- NapCat 数据（账号配置、缓存、日志）：`0.4/napcat/shell/napcat/{config,cache,logs}/`（已 gitignore）
- 分享部署副本前执行 `node scripts/sanitize-release.mjs`（只清理本应用数据，不动第三方目录）

## 6. 本机验证记录（2026-10-24）

- `npm install` 正常；Electron 二进制缺失时用 `node node_modules/electron/install.js` 补齐
- `npm test`：24 个测试套件全部通过（exit 0）
- 扫码登录成功；登录后 NapCat 自动按 `onebot11.json` 模板开启 3000/3001
- 模型连通测试：`POST /api/test/api` → `{ok:true, model:"deepseek-flash", reply:"pong", latencyMs:1438}`
- 私聊端到端验证（已加入白名单）：收到消息 → 模型回复 → 通过 OneBot 发出，
  会话记录 2 轮、约 2.2 万 prompt token（其中 1.1 万命中缓存），应用日志有
  `[发送 -> private:xxx]` 记录
- 桌面端由 `启动QQ机器人.bat` 启动成功：窗口「QQ Agent」+ 托盘 + 控制台 3210
- 注：QQ Agent 应用本身不处理「加好友 / 拉群」请求事件，批准这些请求需要
  用 OneBot `set_friend_add_request` / `set_group_add_request`（或临时脚本监听
  request 事件）；白名单可在控制台设置 → 白名单里勾选
