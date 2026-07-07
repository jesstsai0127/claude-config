---
name: antigravity-review
description: Have Google Antigravity CLI (agy) review a whole feature's related files together, then verify and fix the real issues it finds. Use when the user wants a second-opinion review before or after implementing changes.
argument-hint: [feature name or description]
allowed-tools: Bash(agy -p *) Read Edit Grep
---

## 目的
用 antigravity CLI（`agy`）的 headless 模式對「一個功能涉及的所有檔案」一次做一輪 review，
取得結構化清單後，自己逐條驗證再動手修，不盲目照單全收 antigravity 的輸出——跟對待任何
lint/review 工具一樣。

**範圍是功能，不是單一檔案**：跨檔案的問題（例如 A 檔案呼叫 B 檔案函式的方式不對、共用的資料
結構在多處假設不一致）只有把相關檔案放進同一次 review 才看得到，逐檔案分開跑會漏掉。

## 步驟

1. **界定功能範圍**：`$ARGUMENTS` 是功能名稱或描述。找出這個功能涉及的完整檔案集合：
   - 先查最近跟這個功能相關的 commit（`git log --oneline --all -- <關鍵字>` 或
     `git log -p` 找相關檔名）
   - 用 Grep 找功能關鍵字/函式名稱牽涉到的檔案
   - 不確定的話，列出目前找到的檔案清單，跟使用者確認範圍完整、沒有漏掉相關檔案
   - 若 `$ARGUMENTS` 為空，改用 `git diff --stat` 抓目前有異動的檔案當範圍，一樣要確認

2. **一次呼叫 agy，餵入完整檔案集合**：不要逐檔案個別呼叫。把整組相關檔案路徑列進同一個
   prompt，讓 agy 在同一次 review 裡看到檔案之間的關聯。**一定要帶 `--model "Gemini 3.1 Pro (High)"`**
   ——品質優先於速度/成本，預設值（Flash Medium）不夠強。檔案多的話拉長 timeout：
   ```bash
   agy -p "Review these files together as one feature (list cross-file issues too, not just per-file bugs): <檔案清單>. Output as a plain numbered list: file:line - one sentence issue description. If no bugs, say 'no bugs found'. Do not explain your process, just the list." --model "Gemini 3.1 Pro (High)"
   ```

   **如果 agy 回覆說它需要更多資訊/上下文才能完成 review**（不是給出結構化清單，而是反問
   問題、要求補充某個檔案內容、某個函式定義等）：由我自己去找答案（Read 對應檔案、Grep
   相關定義）再重新呼叫 agy 補上，不要把這個問題丟給使用者處理——使用者要的是結果，
   不是幫兩個 AI 之間傳話。只有在真的需要使用者才知道的資訊（例如背後的產品決策、
   為什麼這樣設計）時，才回頭問使用者。

3. **解析輸出**：把 agy 回傳的每一條 `file:line - 描述` 拆開。

4. **逐條驗證並給出自己的立場**：對每一條，用 Read 打開對應檔案的該行附近，自己判斷是否
   為真的 bug，並明確寫出**我自己的判斷跟理由**（同意/不同意/部分同意 agy 的診斷、為什麼、
   如果有更好的修法直接說），不是只標 true/false。不要假設 agy 一定是對的——它偶爾會誤報
   或誤解上下文；也不要因為 agy 講得有道理就照抄它的措辭，要用自己的話講清楚判斷依據。

5. **修正真的問題**：確認是真 bug 的才用 Edit 修正，維持最小範圍修改，不要順手重構周邊
   不相關的程式碼。

6. **回報結果**：每一條都要列出「agy 的說法」+「我的立場與理由」+「處理結果（修了/跳過）」，
   不是只回結論。讓使用者看得出哪些是我認同、哪些是我推翻 agy 的判斷、為什麼。

## 注意事項
- `agy` 每次呼叫都會打外部 AI 服務（Google Antigravity 後端）；使用者直接呼叫這個 skill
  就是對這次呼叫的授權，不用每條 review 額外再問一次
- 如果 review 範圍會碰到機密檔案（`.env`、`secrets/`），先跟使用者確認要不要排除再送出
- 修正照全域規則一個檔案一個 commit，不要因為是同一輪 review 就打包成一個 commit
