#!/bin/bash
# backup-project.sh
# 備份個別專案（依專案需求，預設用 git bundle，保留完整歷史）
#
# 用法：bash backup-project.sh /path/to/project

set -e

PROJECT_DIR="${1:?請指定專案路徑，例如：bash backup-project.sh ~/projects/personal-os}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
BACKUP_DIR="$HOME/project-backups/$PROJECT_NAME"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

cd "$PROJECT_DIR"

if [ -d ".git" ]; then
  echo "📦 偵測到 git repo，使用 git bundle 備份（含完整歷史）..."
  git bundle create "$BACKUP_DIR/$PROJECT_NAME-$TIMESTAMP.bundle" --all
  echo "✅ 備份完成：$BACKUP_DIR/$PROJECT_NAME-$TIMESTAMP.bundle"
  echo "   還原方式：git clone $BACKUP_DIR/$PROJECT_NAME-$TIMESTAMP.bundle restored-$PROJECT_NAME"
else
  echo "⚠️  非 git repo，改用 tar 打包（不含版本歷史）..."
  tar -czf "$BACKUP_DIR/$PROJECT_NAME-$TIMESTAMP.tar.gz" \
    --exclude='node_modules' \
    --exclude='.venv' \
    --exclude='__pycache__' \
    -C "$(dirname "$PROJECT_DIR")" "$PROJECT_NAME"
  echo "✅ 備份完成：$BACKUP_DIR/$PROJECT_NAME-$TIMESTAMP.tar.gz"
fi

# 只保留最近 5 份
EXCESS=$(ls -t "$BACKUP_DIR"/*.{bundle,tar.gz} 2>/dev/null | tail -n +6)
if [ -n "$EXCESS" ]; then
  echo "$EXCESS" | xargs rm
  echo "🧹 已清除舊備份，保留最近 5 份"
fi
