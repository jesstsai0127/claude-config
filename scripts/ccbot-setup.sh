#!/bin/bash
# ccbot-setup.sh
# 在 YYDS（master 機器）上安裝設定 ccbot
# 前置需求：tmux、Claude Code CLI 已安裝

set -e

echo "📦 安裝 ccbot..."
if command -v uv &> /dev/null; then
  uv tool install git+https://github.com/six-ddc/ccbot.git
else
  pipx install git+https://github.com/six-ddc/ccbot.git
fi

echo ""
echo "⚙️  接下來需要手動完成以下步驟："
echo ""
echo "1. 用 @BotFather 建立 Telegram Bot，取得 Token"
echo "   - 對話 @BotFather → /newbot → 依指示建立"
echo "   - 開啟該 Bot 個人頁面 → Open App → Settings > Bot Settings"
echo "   - 啟用 Threaded Mode（話題模式），這是 ccbot 運作的必要設定"
echo ""
echo "2. 建立設定檔 ~/.ccbot/.env："
echo "   mkdir -p ~/.ccbot"
echo "   cat > ~/.ccbot/.env << 'EOF'"
echo "   TELEGRAM_BOT_TOKEN=你的_bot_token"
echo "   ALLOWED_USERS=你的_telegram_user_id"
echo "   EOF"
echo ""
echo "3. 安裝 SessionStart hook（讓 ccbot 自動追蹤 Claude session）："
echo "   ccbot hook --install"
echo ""
echo "4. 啟動 ccbot tmux session："
echo "   tmux new -s ccbot"
echo "   ccbot"
echo ""
echo "5. 之後要在某個專案開新的 Claude session 給 ccbot 接管："
echo "   tmux attach -t ccbot"
echo "   tmux new-window -n myproject -c ~/path/to/project"
echo "   claude"
echo ""
echo "6. 重大決策確認流程：ccbot 會把 Permission Prompt 以 inline keyboard"
echo "   推到 Telegram，直接在手機上點選即可回應，不需要回到電腦前"
echo ""
echo "✅ 腳本執行完畢，請依上述步驟手動完成 Telegram Bot 設定"
