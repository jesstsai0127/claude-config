#!/bin/bash
# backup-config.sh
# 備份 ~/.claude 設定本身（CLAUDE.md、settings、rules、skills）
# 讓你的 Claude Code 環境可以還原，避免設定被寫死或損毀

set -e

BACKUP_DIR="$HOME/claude-config-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/claude-config-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_FILE" \
  -C "$HOME" .claude \
  --exclude='.claude/projects/*/cache' \
  --exclude='.claude/projects/*/logs' \
  2>/dev/null

echo "✅ 備份完成：$BACKUP_FILE"

# 只保留最近 10 份
EXCESS=$(ls -t "$BACKUP_DIR"/claude-config-*.tar.gz 2>/dev/null | tail -n +11)
if [ -n "$EXCESS" ]; then
  echo "$EXCESS" | xargs rm
  echo "🧹 已清除舊備份，保留最近 10 份"
fi
