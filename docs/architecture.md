# 整體架構（給 Claude Code 看的環境地圖）

> 這份文件描述 Mr. J 的多機器協同架構，任何涉及跨機器派工的任務，
> 先讀這份文件確認目前的機器清單與角色，再決定怎麼執行。

## 機器清單

| 名稱 | Tailscale hostname | 角色 | 作業系統 | 備註 |
|---|---|---|---|---|
| YYDS | yyds | Master，全時運作 | Ubuntu Linux | n8n、Docker、ccbot 都跑在這 |
| hp-desktop | hp-desktop | Worker，臨時接入 | Windows | 目前開發實際會用的第二台機器 |
| （未來機器） | | | | |

## 角色定義

### YYDS（Master）
- 全時開機運作，是所有自動化的核心
- n8n、Docker、Tailscale、ccbot 都跑在這台
- 預設所有不需要特定環境（GPU、Windows-only 軟體）的任務都在這裡執行
- 重大決策一律透過 ccbot 推送到 Telegram，等待 Mr. J 確認後才繼續

### hp-desktop（Worker）
- 不是全時開機，任務派工前先確認是否在線（透過 Tailscale ping 或 `tailscale status`）
- 用途：需要 Windows 特有環境、或 Mr. J 正在該機器前操作時
- 目前開發階段只用 YYDS + hp-desktop 兩台機器

## 派工判斷邏輯

```
收到任務
  ├─ 需要特定環境（GPU / Windows-only / 特定軟體）？
  │   ├─ 是 → 確認對應機器在線 → SSH 派工過去 → 結果回傳 YYDS 彙整
  │   └─ 否 → 在 YYDS 本機執行
  └─ 涉及架構變更 / 刪除資料 / 花錢 / 對外發布？
      └─ 一律先透過 ccbot 詢問 Mr. J，得到確認後才執行
```

## 通訊方式

- 機器之間：Tailscale（私有網路，不對外開 port）
- 派工指令：SSH（透過 Tailscale 網路）
- 人機溝通：
  - 人在電腦前：ccmux（本機 TUI 介面）
  - 人不在電腦前：ccbot（Telegram）

## 設定同步

所有機器的 Claude Code 設定（CLAUDE.md、settings.json、rules）
來自同一個 GitHub repo，用 scripts/sync-config.sh 同步，
不要在個別機器手動修改設定後忘記同步回 repo。

## 待補充

- [ ] 確認 hp-desktop 是否已安裝 Claude Code + tmux（若要派工過去執行任務）
- [ ] 未來新增機器時，回來更新這份文件的機器清單
