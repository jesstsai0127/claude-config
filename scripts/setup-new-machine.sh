#!/bin/bash
# setup-new-machine.sh
# 新環境一鍵套用：clone 這個 repo、symlink 設定到 ~/.claude，
# 並視角色（master/worker）安裝對應工具
#
# 用法：bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/claude-config/main/scripts/setup-new-machine.sh)

set -e

GITHUB_USERNAME="YOUR_GITHUB_USERNAME"   # ← 換成你的 GitHub 帳號
REPO_NAME="claude-config"
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
CLONE_DIR="$HOME/.claude-config-source"

echo "📦 Clone 設定 repo..."
if [ -d "$CLONE_DIR/.git" ]; then
  echo "  已存在，執行 git pull..."
  cd "$CLONE_DIR" && git pull
else
  git clone "$REPO_URL" "$CLONE_DIR"
fi

echo "🔗 建立 symlink..."
mkdir -p "$HOME/.claude/rules"

ln -sf "$CLONE_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
echo "  ✅ ~/.claude/CLAUDE.md"

ln -sf "$CLONE_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
echo "  ✅ ~/.claude/settings.json"

for f in "$CLONE_DIR/.claude/rules/"*.md; do
  fname=$(basename "$f")
  ln -sf "$f" "$HOME/.claude/rules/$fname"
  echo "  ✅ ~/.claude/rules/$fname"
done

chmod +x "$CLONE_DIR/scripts/"*.sh
echo "  ✅ scripts/ 已設為可執行"

echo ""
echo "🤔 這台機器的角色是？"
echo "   1) Master（全時運作，例如 YYDS）— 會安裝 ccbot"
echo "   2) Worker / 日常操作機 — 會安裝 ccmux"
echo "   3) 都要"
echo "   4) 都不要，稍後手動安裝"
read -p "請輸入 1-4: " role

case "$role" in
  1)
    bash "$CLONE_DIR/scripts/ccbot-setup.sh"
    ;;
  2)
    bash "$CLONE_DIR/scripts/ccmux-setup.sh"
    ;;
  3)
    bash "$CLONE_DIR/scripts/ccbot-setup.sh"
    bash "$CLONE_DIR/scripts/ccmux-setup.sh"
    ;;
  *)
    echo "略過工具安裝，稍後可手動執行 scripts/ccbot-setup.sh 或 scripts/ccmux-setup.sh"
    ;;
esac

echo ""
echo "📚 是否要套用 andrej-karpathy-skills（CLAUDE.md 行為強化，低成本提升程式品質）？"
read -p "(y/N): " install_karpathy
if [ "$install_karpathy" = "y" ]; then
  mkdir -p "$HOME/.claude/skills"
  curl -fsSL https://raw.githubusercontent.com/karpathy/andrej-karpathy-skills/main/CLAUDE.md \
    -o "$HOME/.claude/skills/karpathy-principles.md" 2>/dev/null \
    && echo "  ✅ 已下載到 ~/.claude/skills/karpathy-principles.md（請手動確認實際 repo 路徑是否正確）" \
    || echo "  ⚠️  下載失敗，請手動至 GitHub 搜尋 andrej-karpathy-skills 確認正確路徑"
fi

echo ""
echo "🎉 設定完成！"
echo "   設定來源：$CLONE_DIR"
echo "   下次更新：bash $CLONE_DIR/scripts/sync-config.sh pull"
echo ""
echo "⚠️  記得："
echo "   1. 確認 .claude/settings.json 的 allowedDomains 符合目前專案需求"
echo "   2. 更新 docs/architecture.md，填入這台機器的 Tailscale hostname 與角色"
echo "   3. 若這台是 master，依 scripts/ccbot-setup.sh 的指示完成 Telegram Bot 設定"
