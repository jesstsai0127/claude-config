---
paths: []
---

# 先查專家社群再設計

## 技術問題，依序查證

1. **官方文件優先**
   - Claude Code: https://docs.claude.com
   - Anthropic 原廠更新: https://www.anthropic.com/news
   - n8n: https://community.n8n.io + https://docs.n8n.io
   - Notion API: https://developers.notion.com
   - Telegram Bot API: https://core.telegram.org/bots/api
   - Ollama: https://ollama.com + https://github.com/ollama/ollama
   - Gemini API: https://ai.google.dev
   - Docker: https://docs.docker.com
   - Tailscale: https://tailscale.com/kb

2. **官方 GitHub issue / discussions**
   確認是否已有人問過同樣問題，特別是該技術的 GitHub repo 的 open/closed issues

3. **Claude Code 生態系策展**
   https://github.com/hesreallyhim/awesome-claude-code
   確認是否已有現成工具或 skill 解決，不要重新發明

4. **只有以上都找不到，才開始自行設計**
   並且說明「這是自行推導的方案，建議完成後在以上來源二次確認」

## Token 與 context 管理原則

- 長對話出現明顯品質下降（重複提到已解決的問題、答非所問）時，
  主動建議 /clear 或 /compact，不要在污染的 context 裡繼續工作
- 子任務複雜度與模型選擇要匹配，不要用 Opus 做 Haiku 等級的任務
- 每次 session 開始，CLAUDE.md 就已消耗固定 token，規則要精簡

## 使用外部程式碼的 code review 清單

引用任何來自網路、GitHub 的程式碼前，確認：
- [ ] 授權條款（MIT / Apache / GPL 等，是否與本專案相容）
- [ ] 最後更新時間（超過一年未維護要特別說明）
- [ ] 是否有已知安全漏洞（檢查 repo 的 security advisory）
- [ ] 寫法是否符合本專案的語言版本與慣例
- [ ] 是否有更官方或更主流的替代方案
