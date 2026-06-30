# claude-config

Mr. J 的 Claude Code 個人設定包。新環境一鍵套用，支援多機器協同。

## 包含內容

```
claude-config/
├── CLAUDE.md                        # 全域行為規則（語言、互動節奏、多機器協同、思考框架）
├── .claude/
│   ├── settings.json                # 權限規則 + sandbox + allowedDomains
│   └── rules/
│       ├── research-first.md        # 先查專家社群再設計的流程
│       └── git-worktree.md          # 多 agent / 多機器並行時的隔離規則
├── docs/
│   └── architecture.md              # 機器清單、角色定義、派工邏輯（給 Claude Code 看的環境地圖）
├── scripts/
│   ├── setup-new-machine.sh         # 新環境一鍵套用（含角色選擇）
│   ├── ccbot-setup.sh               # 安裝設定 ccbot（Telegram 遠端操作）
│   ├── ccmux-setup.sh               # 安裝 ccmux（本機 UI friendly 介面）
│   ├── sync-config.sh               # 多機器設定同步（pull/push）
│   ├── backup-config.sh             # 備份 ~/.claude 設定本身
│   ├── backup-project.sh            # 備份個別專案（git bundle 或 tar）
│   └── daily-digest.sh              # 供 n8n 呼叫，巡查生態系更新
├── .gitignore
└── README.md
```

## 工具定位（重要，先搞清楚再裝）

| 工具 | 用途 | 何時用 |
|---|---|---|
| **ccmux** (Shin-sibainu/ccmux) | 單機 UI friendly terminal，取代原生 terminal | 人在電腦前操作時 |
| **ccbot** (six-ddc/ccbot) | Telegram ↔ tmux bridge | 人不在電腦前，遠端確認/下指令 |
| **Tailscale + SSH** | 跨機器派工 | YYDS 派任務給其他機器執行 |

ccmux 和 ccbot 都是建立在同一個 tmux session 之上的不同介面，不是互斥的兩套系統——同一個 Claude Code session，在電腦前用 ccmux 看，離開後用 ccbot 在 Telegram 上繼續操作。

## 架構總覽

```
你（Telegram，透過 ccbot）
    ↕ 確認重大決策
YYDS（Master，全時運作）
  ├─ tmux session：ccbot 接管，Telegram 可隨時介入
  ├─ 一般任務：本機執行
  └─ 需要特定環境的任務 → SSH 派工給其他機器（Tailscale 內網）
```

詳細機器清單與派工邏輯見 `docs/architecture.md`，**請務必在第一次設定時填入實際的 Tailscale hostname**。

## 新環境安裝（一行指令）

先把 `YOUR_GITHUB_USERNAME` 換成你的帳號：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/claude-config/main/scripts/setup-new-machine.sh)
```

腳本會詢問這台機器的角色（master/worker/都要），自動安裝對應工具。

## 手動安裝

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/claude-config.git ~/.claude-config-source
cd ~/.claude-config-source
bash scripts/setup-new-machine.sh
```

## 多機器設定同步

```bash
# 拉取其他機器/GitHub 上的最新設定
bash ~/.claude-config-source/scripts/sync-config.sh pull

# 把本機修改的設定推回 GitHub，讓其他機器之後可以拉取
bash ~/.claude-config-source/scripts/sync-config.sh push
```

## 備份

```bash
# 備份 Claude Code 設定本身
bash ~/.claude-config-source/scripts/backup-config.sh

# 備份個別專案（依專案類型自動選 git bundle 或 tar）
bash ~/.claude-config-source/scripts/backup-project.sh ~/projects/personal-os
```

備份存在 `~/claude-config-backups/`（設定）與 `~/project-backups/`（專案），自動保留最近數份。

## 每日生態系巡查（接 n8n）

`scripts/daily-digest.sh` 抓取 Claude Code 生態系更新與 Anthropic 官方公告，
輸出 JSON。設計上由 n8n cron workflow 呼叫，n8n 負責判斷是否值得推送 Telegram 通知，
避免每天都打擾你。這支腳本本身不直接發送通知。

## 設計原則

- **程式優先於對話**：重複性任務寫成腳本或 n8n workflow，不靠每次對話解決
- **本機優先**：程式碼與設定留在本機，不預設上雲端
- **規劃先於實作**：架構決策先提計畫確認後才動手
- **精簡 CLAUDE.md**：每行都消耗 token，只寫 Claude 無法自行推斷的規則
- **重大決策必須確認**：即使是全時運作的 master 機器，架構變更、刪除資料、
  花費金錢、對外發布一律透過 ccbot 詢問，不自動執行

## 機密管理

所有 `.env`、API key、bot token 一律放在本機，不進 git。
已在 `.gitignore` 中排除常見的機密檔案命名模式。
