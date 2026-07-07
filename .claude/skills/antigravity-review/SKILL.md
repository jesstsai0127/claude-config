---
name: antigravity-review
description: Have Google Antigravity CLI (agy) review code, then verify and fix the real issues it finds. Use when the user wants a second-opinion review before or after implementing changes.
argument-hint: [path or description of what to review]
disable-model-invocation: true
allowed-tools: Bash(agy -p *) Read Edit Grep
---

## 目的
用 antigravity CLI（`agy`）的 headless 模式對指定範圍做一輪 review，取得結構化清單後，
自己逐條驗證再動手修，不盲目照單全收 antigravity 的輸出——跟對待任何 lint/review 工具一樣。

## 步驟

1. **決定 review 範圍**：`$ARGUMENTS` 是要 review 的檔案/目錄/描述。若為空，改用
   `git diff --stat` 找出目前有異動的檔案當範圍，並跟使用者確認範圍是否正確。

2. **呼叫 agy**：在目標目錄下執行，依範圍調整 prompt 內容與 timeout（多檔案/整個 repo
   拉長 timeout，agy 執行時間可能超過預設值）：
   ```bash
   agy -p "Review <範圍> for bugs only. Output as a plain numbered list: file:line - one sentence issue description. If no bugs, say 'no bugs found'. Do not explain your process, just the list."
   ```

3. **解析輸出**：把 agy 回傳的每一條 `file:line - 描述` 拆開。

4. **逐條驗證**：對每一條，用 Read 打開對應檔案的該行附近，自己判斷是否為真的 bug。
   不要假設 agy 一定是對的——它偶爾會誤報或誤解上下文。

5. **修正真的問題**：確認是真 bug 的才用 Edit 修正，維持最小範圍修改，不要順手重構周邊
   不相關的程式碼。

6. **回報結果**：條列出「修了什麼（檔案:行號 + 一句話）」跟「跳過了什麼、為什麼判斷是
   誤報」，讓使用者知道哪些是自己驗證過的判斷，不是照單全收 agy 的輸出。

## 注意事項
- `agy` 每次呼叫都會打外部 AI 服務（Google Antigravity 後端）；使用者直接呼叫這個 skill
  就是對這次呼叫的授權，不用每條 review 額外再問一次
- 如果 review 範圍會碰到機密檔案（`.env`、`secrets/`），先跟使用者確認要不要排除再送出
- 修正照全域規則一個檔案一個 commit，不要因為是同一輪 review 就打包成一個 commit
