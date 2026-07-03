#!/bin/bash
# sync-config.sh
# 多機器設定同步：把本機 ~/.claude 的設定變更推回 GitHub repo，
# 或把 repo 最新版本拉到本機（依參數決定方向）
#
# 用法：
#   bash sync-config.sh pull   # 從 GitHub 拉最新設定到本機（預設）
#   bash sync-config.sh push   # 把本機設定的修改推回 GitHub

set -e

CLONE_DIR="$HOME/.claude-config-source"
MODE="${1:-pull}"

if [ ! -d "$CLONE_DIR/.git" ]; then
  echo "❌ 找不到 $CLONE_DIR，請先執行 setup-new-machine.sh"
  exit 1
fi

cd "$CLONE_DIR"

if [ "$MODE" = "pull" ]; then
  echo "⬇️  從 GitHub 拉取最新設定..."
  git pull
  echo "✅ 完成，symlink 已自動生效（不需重啟 Claude Code，下次對話即套用新規則）"

elif [ "$MODE" = "push" ]; then
  echo "⬆️  檢查本機設定是否有修改..."
  git status --short

  if [ -z "$(git status --short)" ]; then
    echo "沒有變更，不需要推送"
    exit 0
  fi

  echo ""
  read -p "確認要把以上變更推回 GitHub？(y/N) " confirm
  if [ "$confirm" != "y" ]; then
    echo "已取消"
    exit 0
  fi

  git add -A
  read -p "簡述這次變更內容：" commit_msg
  git commit -m "$commit_msg"
  git push
  echo "✅ 已推送，其他機器執行 sync-config.sh pull 即可同步"

else
  echo "用法：sync-config.sh [pull|push]"
  exit 1
fi
