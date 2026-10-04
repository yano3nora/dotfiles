# TASK-261004: dotfiles 自身に gitleaks の pre-commit を入れる

261004 gitleaks-pre-commit
===

## asis

- この repo は public で、commit した時点で secret は漏洩になる
- commit 前の secret 検査がなく、人間の注意だけに依存している
- gitleaks は `mise/mac.toml` に入っているが、何にも使っていない

## tobe

- commit 前に、stage した内容を gitleaks で scan して止める
- 適用の入口は `dots link` のまま増やさない
- Windows サブ機でも同じ hook が動く

## todo

- [x] `git/hooks/pre-commit` を置く。中身は `gitleaks git --pre-commit --staged` の 1 行
- [x] `bin/dots` の `link_all` に `.git/hooks/pre-commit` への symlink を足す
- [x] `bin/dots` の `doctor` に `gitleaks` を足す
- [x] `mise/win.toml` に `gitleaks` を足し、`windows/copy-configs.sh` で hook をコピーする
- [x] README / `git/README.md` / `windows/README.md` を更新する
- [x] `dots link` で実機に hook を張る
- [x] `project/` の template も gitleaks に寄せる。`project/mise.toml` の例に tools と pre-commit を足し、`project/typescript` に一度入れた secretlint は外す
- [x] Codex レビュー。worktree 対応で hook の置き場を `git rev-parse --git-path` に変えた
- [ ] Windows サブ機で `mise install` と `copy-configs.sh` を流す (人間)

## testcases

- [x] worktree と全履歴を gitleaks で scan して 0 件
- [x] 偽の GitHub token を stage して hook が exit 1 で止まり、secret は REDACTED で出る
- [x] 何も stage していなければ hook は exit 0 で何も出さない
- [x] 一時 clone に `HOME=<tmp> dots link` して hook の symlink だけが新規に張られる
- [x] `zsh -n bin/dots`、`bash -n windows/copy-configs.sh` が通る
- [ ] Windows で `git commit` 時に hook が動く

## notes

- secretlint ではなく gitleaks にした。理由: global mise に入っていて、Node 不要の単体バイナリ
- `--staged` は index を見る。作業ツリーだけ直して再 stage し忘れても見逃さない
- gitleaks が PATH に無いと exit 127 で commit が止まる。fail-closed なので許容する
    - GUI から commit する場合は mise の shim が PATH に要る
- `core.hooksPath` で全 repo に効かせる案は採らない。理由: project ごとの hook を潰す
- 誤検知は該当行の `gitleaks:allow` コメントで抑える。`.gitleaksignore` は増やさない
- `git commit --no-verify` は素通りする。残リスクとして受け入れる
