#!/bin/bash
# daily-digest.sh
# 供 n8n cron workflow 呼叫，巡查 Claude Code 生態系更新
# 結果輸出 JSON，讓 n8n 決定是否推送 Telegram 通知

set -e

OUTPUT_FILE="/tmp/claude-digest-$(date +%Y%m%d).json"

# 1. 抓取 awesome-claude-code 最新 commit 訊息（最近 3 筆）
AWESOME_COMMITS=$(curl -s \
  "https://api.github.com/repos/hesreallyhim/awesome-claude-code/commits?per_page=3" \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
results = []
for item in data:
    results.append({
        'date': item['commit']['author']['date'],
        'message': item['commit']['message'].split('\n')[0]
    })
print(json.dumps(results))
" 2>/dev/null || echo "[]")

# 2. 抓取 Anthropic news RSS（標題列表）
ANTHROPIC_NEWS=$(curl -s "https://www.anthropic.com/news" \
  | grep -o '<title>[^<]*</title>' \
  | head -5 \
  | sed 's/<[^>]*>//g' \
  | python3 -c "
import sys, json
lines = [l.strip() for l in sys.stdin if l.strip()]
print(json.dumps(lines))
" 2>/dev/null || echo "[]")

# 3. 組合輸出
python3 -c "
import json, sys
from datetime import datetime

result = {
    'generated_at': datetime.now().isoformat(),
    'awesome_claude_code': $AWESOME_COMMITS,
    'anthropic_news': $ANTHROPIC_NEWS
}
print(json.dumps(result, ensure_ascii=False, indent=2))
" > "$OUTPUT_FILE"

echo "✅ Digest 產生完成：$OUTPUT_FILE"
cat "$OUTPUT_FILE"

# 提醒：這支腳本只負責「抓資料 + 摘要」，是否推送 Telegram 通知
# 由 n8n workflow 接手判斷（例如只有偵測到關鍵字才推播，避免每天都打擾）
