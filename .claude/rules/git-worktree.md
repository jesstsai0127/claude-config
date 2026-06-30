---
paths: []
---

# Git Worktree 隔離規則

## 何時使用 worktree

- 同時有兩個以上「會修改程式碼」的 Claude Code session 在同一個 repo 工作時，
  一律使用 git worktree 各自獨立分支，不要共用同一個 working directory
- 派工到其他機器執行的任務，若涉及修改程式碼，也建議在該機器上對應的 worktree 內進行

## 標準流程

```bash
# 建立 worktree（從目前分支建立新分支）
git worktree add ../project-feature-x -b feature-x

# 查看所有 worktree
git worktree list

# 完成後移除
git worktree remove ../project-feature-x
```

## 命名慣例

- worktree 路徑：`../{repo名稱}-{任務簡述}`
- 分支名稱：`feature-{簡述}` 或 `fix-{簡述}`，與任務內容對應，方便事後追蹤

## 注意事項

- worktree 之間共用同一個 `.git`，但 working directory 完全獨立，不會互相干擾
- 任務完成並合併回主分支後，記得移除 worktree 釋放空間
- 不要在多個 worktree 同時對同一個檔案做衝突性修改，先確認任務分工不重疊
