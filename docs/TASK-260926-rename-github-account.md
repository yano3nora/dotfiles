# TASK-260926: GitHub ユーザー名を yano3nora から y3n608 へ変更

260926 GitHub ユーザー名を yano3nora から y3n608 へ変更
===

## asis

- GitHub ユーザー名は `yano3nora`。ハンドルネームと本名の混合で、どの場でも使いづらい
- 新ユーザー名 `y3n608` は 2026-09-26 時点で GitHub 上で未使用
- ローカルの macOS user / `~/git/yano3nora/` は `y3n` / `yano3nora` の混在
- dotfiles 内の `yano3nora` 依存
    - `git/gitconfig`: `name`、noreply email `18728262+yano3nora@users.noreply.github.com`
    - `mise/config.toml`: `github:yano3nora/*` 6 件 (gistan / coda / excel2json / kawsay / rubylize / jsonalize)
    - `gh/extensions.txt`: `yano3nora/gh-bprune`, `yano3nora/gh-review-prompt`
    - `vscode/settings.json`, `vscode/README.md`: jsdelivr の CSS URL
    - `README.md`, `docs/TASK-260912-*.md`, `coda/README.md`, `zsh/zshrc.d/30-alias.zsh`: clone URL / リンク / コメント
    - `gistan/config.toml`, `zsh/zshrc.d/30-alias.zsh`: ローカルパス `~/git/yano3nora/...`
- ローカル repo の remote (`~/git/yano3nora/*`) は `git@github.com:yano3nora/*.git`
- 会社 org 配下の repo は remote に個人名を含まない。ただし `CODEOWNERS` / branch protection の reviewer に `@yano3nora` が入っている可能性がある
- `gh` の `~/.config/gh/hosts.yml` に `user: yano3nora` が保存されている

## tobe

- GitHub ユーザー名が `y3n608` になり、旧名 `yano3nora` は第三者に取られない
- dotfiles / ローカル repo / 外部サービスの参照が新名に揃い、旧名リダイレクトに依存しない
- ローカルディレクトリ `~/git/yano3nora/` は当面そのまま。ディレクトリ改名は別 task にする
    - 理由: Claude Code / Codex の project 記憶、alias、gistan 設定がパス依存で影響が広い

## todo

### Phase 0: 事前棚卸し (改名前)

- [ ] `gh repo list yano3nora --limit 200` で owner repo を一覧にして notes に貼る
- [ ] `yano3nora.github.io` repo の有無を確認する。あれば Pages の URL 変更を影響に含める
- [ ] ghcr.io / GitHub Packages の利用有無を確認する
- [ ] gist の利用有無と、外部に貼った gist URL の有無を確認する
- [ ] 会社 org repo で `CODEOWNERS` に `@yano3nora` が入っているものを grep する
- [ ] GitHub OAuth で連携中の外部サービスを Settings → Applications で一覧にする
    - 候補: Vercel / Netlify / Firebase / Cloudflare / npm / Codex / Claude Code / Raycast など
- [ ] 旧名 `yano3nora` を捨てアカウントで押さえるか決める。決定を notes に書く

### Phase 1: GitHub 側の改名

- [ ] Settings → Account → Change username で `y3n608` に変更する
- [ ] 旧名を押さえるなら、直後に別メールで `yano3nora` アカウントを作る
- [ ] `yano3nora.github.io` があれば `y3n608.github.io` に rename する
- [ ] profile / bio / pinned の表示名を確認する

### Phase 2: ローカル環境の追従

- [ ] `gh auth logout -h github.com -u yano3nora` → `gh auth login` で再認証する
- [ ] `git/gitconfig` の `name` と noreply email を `18728262+y3n608@users.noreply.github.com` に変える
- [ ] `mise/config.toml` の `github:yano3nora/*` を `github:y3n608/*` に置換し、`mise install` で取得できることを確認する
- [ ] `gh/extensions.txt` を `y3n608/*` に置換し、`gh extension list` で動作確認する
- [ ] `vscode/settings.json` / `vscode/README.md` の jsdelivr URL を新名にし、purge URL を叩く
- [ ] `README.md` / `coda/README.md` / `zsh/zshrc.d/30-alias.zsh` のリンク・コメントを新名にする
- [ ] `~/git/yano3nora/*` 各 repo で `git remote set-url origin git@github.com:y3n608/<repo>.git` を実行する
- [ ] `~/git/yano3nora/dotfiles` の submodule URL に旧名が含まれないか `.gitmodules` を確認する

### Phase 3: 外部の追従

- [ ] 会社 org repo の `CODEOWNERS` / reviewer 設定を `@y3n608` に修正する (PR を出す)
- [ ] Phase 0 で洗い出した外部サービスの表示名 / import path を確認し、必要なら再連携する
- [ ] npm / Homebrew tap / README badge など、公開物に埋まった旧名 URL を修正する
- [ ] SNS / ブログ / 名刺などの GitHub リンクを更新する

### Phase 4: Gmail アドレスの変更

- [ ] myaccount.google.com → 個人情報 → メール で「Google アカウントのメールアドレスを変更」が出るか確認する。日本での提供有無が未確認のため
- [ ] `y3n608@gmail.com` の空きを確認する
- [ ] 変更前に「Google でログイン」を使っている外部サービスを Settings → セキュリティ → サードパーティ で一覧にする
- [ ] Gmail アドレスを `y3n608@gmail.com` に変更する
- [ ] GitHub の primary email を新アドレスに変え、旧アドレスは secondary として残す
- [ ] 主要サービスの登録メールを新アドレスに変える。旧アドレスは alias として届くので急がない

## testcases

- [ ] `ssh -T git@github.com` の応答が `Hi y3n608!` になる
- [ ] `gh auth status` が `y3n608` で logged in になる
- [ ] `git commit` の author が GitHub 上で新名のアカウントに紐づく
- [ ] `mise install` で `github:y3n608/*` の 6 tool が取得できる
- [ ] `gh extension list` で 2 extension が新名で動く
- [ ] jsdelivr の CSS URL が VSCode の markdown preview で反映される
- [ ] `~/git/yano3nora/*` 各 repo で `git fetch` が通る
- [ ] `https://github.com/yano3nora/dotfiles` が新名へ redirect する
- [ ] 会社 org repo で PR を作り、CODEOWNERS による review request が飛ぶ
- [ ] `grep -rn yano3nora --exclude-dir=.git --exclude-dir=plugins .` の結果が、ローカルパスと過去 task の記録だけになる
- [ ] 旧 Gmail アドレス宛のメールが新アドレスの受信箱に届く
- [ ] 「Google でログイン」を使う主要サービスに新アドレスでログインできる

## notes

- 旧名は改名直後に空きになる。第三者が取得すると repo redirect が壊れる
- redirect されないもの: profile URL / `CODEOWNERS` / 過去 issue・PR 本文の @mention / Pages / ghcr.io の path
- 影響しないもの: SSH key / PAT / OAuth 連携 / org membership。account ID 紐づけのため
- noreply email は ID 部分で紐づく。旧 email の commit も新アカウントに紐づく。ただし新規 commit は新名で揃える
- Gmail アドレスは 2026 年から変更可能になった。旧アドレスは alias として残り、削除不可、第三者も取得不可
    - 制約: 12 ヶ月に 1 回、生涯 3 回まで。旧アドレスへの戻しはいつでも可能
    - 米国から提供開始。日本での提供有無は Phase 4 で実機確認する
    - 「Google でログイン」の外部サービスに影響が出る可能性あり。公式ヘルプが明記している
    - 出典: https://support.google.com/accounts/answer/19870
- GitHub と Gmail は同じ名前で揃える。Gmail は生涯 3 回制限があるので、名前は先に確定させる
- ローカルディレクトリ `~/git/yano3nora/` の改名は別 task。影響先: Claude Code project 記憶、alias `cdd`、`gistan/config.toml`
- 参考: https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-personal-account-settings/changing-your-github-username
