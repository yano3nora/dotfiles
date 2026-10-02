# TASK-261002: チーム配布用に skills を別 repo `skills` へ切り出す

261002 チーム配布用に skills を別 repo `skills` へ切り出す
===

## asis

- gsheet の実体が 3 か所に散っている: `ai/skills/gsheet/SKILL.md`, `bin/gsheet` + `bin/gsheet.cmd`, `bin/README.md` の setup 節
- 配布先 (社内の mac / Windows) は dotfiles を持たない。`dots link` も `windows/copy-configs.sh` も使えない
- SKILL.md が `bin/README.md` を参照している。配布先にはそのファイルが無い
- show-me / why-me も将来チームで標準化したいが、配布手段が無い

## tobe

- 汎用 skill は public repo `yano3nora/skills` に置く。dotfiles は `ai/skills/yano3nora` の git submodule で持つ
- skill は Agent Skills の標準レイアウト (`SKILL.md` + `scripts/` + `README.md`) で自己完結させる
- 配布先の手順は `git clone` → `./install.sh` → 鍵 JSON を置く、の 3 つ
- chrome-connect も submodule に置く。CLI の導入は SKILL.md が `mise exec` での起動を案内する
- dotfiles 側の正は submodule だけ。`bin/gsheet` と `ai/skills/{gsheet,show-me,why-me}` は消す

## 設計

- repo 分割は「公開できるか」で切る。skill 単位では切らない
    - 汎用: `skills` (public)。社内文脈を含む skill は別の社内 repo に置き、この repo をコピーせず参照する
- `skills/` のレイアウト

    ```
    skills/
    ├── install.sh              # skills/* を ~/.claude/skills, ~/.codex/skills, ~/.local/bin へコピー
    ├── README.md
    └── skills/
        ├── gsheet/{SKILL.md,README.md,scripts/gsheet,scripts/gsheet.cmd}
        ├── show-me/SKILL.md
        └── why-me/{SKILL.md,agents/openai.yaml}
    ```

- `install.sh` は bash 3.2 で書き、mac の zsh からも git bash からも流せる。`windows/copy-configs.sh` と同じく既存ファイルは `.bak.YYYYMMDDHHMMSS` に退避し、同じ中身なら触らない
    - symlink ではなくコピーする。理由: Windows の symlink は開発者モードか管理者権限が要る
    - `scripts/` 配下は `~/.local/bin` にコピーする。理由: Agent は PATH 上のコマンド名で呼ぶ方が安定する。mac の `excludedCommands: ["gsheet *"]` もコマンド名の前方一致
- Claude Code の plugin / marketplace は使わない。理由: Codex が読まない、PATH に script を置けない、sandbox 設定を同梱できない。後から同じ `skills/` を指す marketplace を足すことはできる
- dotfiles 側
    - `bin/dots` の `link_all` は `ai/skills/*/skills/*` を glob で張り、`skills/*/scripts/*` の executable を `~/.local/bin` に張る
    - `windows/copy-configs.sh` は skill と gsheet のコピーを `ai/skills/yano3nora/install.sh` に委譲する
    - 配布先と同じ手順を自分でも踏まない。理由: 自分の環境は symlink で submodule に追従させたい
- 鍵の運用は 1 人 1 鍵。理由: 1 鍵を全員に配ると、1 人の漏洩で全員分の権限が漏れ、個別に失効できない
- mac の `excludedCommands` は `~/.claude/settings.json` の個人設定なので同梱できない。skill の README に手動ステップとして書く

## todo

- [x] `~/git/yano3nora/skills` を作る (install.sh / README.md / skills/*)
- [x] gsheet の SKILL.md / scripts / README を配布先の読者向けに書き直す (dotfiles への参照を消す)
- [x] 人間: GitHub に `yano3nora/skills` (public) を作って push する
- [x] dotfiles に `ai/skills/yano3nora` を submodule 追加する
- [x] `bin/dots` の `link_all` を submodule 参照に切り替える
- [x] `windows/copy-configs.sh` を `install.sh` 委譲に切り替える
- [x] `bin/gsheet`, `bin/gsheet.cmd`, 旧 `ai/skills/{gsheet,show-me,why-me}` を消す
- [x] `bin/README.md`, `ai/README.md`, `windows/README.md`, root `README.md` を直す
- [x] `zsh -n bin/dots` / `bash -n install.sh` / 一時 HOME で `install.sh` と `dots link`
- [x] Codex にレビュー依頼 (P2 3 件 / P3 1 件を反映。notes 参照)
- [x] 人間: Windows 実機で `git clone` → `./install.sh` → `gsheet meta` を確認

## testcases

- [x] 一時 HOME で `install.sh` を流すと `~/.claude/skills/{gsheet,show-me,why-me}`, `~/.codex/skills/*`, `~/.local/bin/{gsheet,gsheet.cmd}` ができ、`gsheet` が executable
- [x] `install.sh` を 2 回流しても `.bak` が増えない。中身を変えると `.bak` に退避する
- [x] `install.sh gsheet` のように引数で絞れる。無い skill 名は非 0 で終了する
- [x] 一時 HOME で `dots link` を流すと skills と `~/.local/bin/gsheet` が submodule 配下への symlink になる。`gsheet.cmd` は張られない
- [x] `~/.local/bin/gsheet --help` が従来どおり出る
- [x] `grep -r 'bin/README\|bin/gsheet' skills/` が 0 件
- [x] Windows git bash と PowerShell で `gsheet meta <id>` が 200 を返す

## notes

- 2026-10-02: chrome-devtools-mcp 1.9.0 で `start --autoConnect` が直ったので、chrome-connect も submodule へ移し `ai/local/` を廃止した。submodule の mount は `ai/shared` から `ai/skills/yano3nora` へ変えた。`ai/skills/<owner>/` に他の人の skills repo も並べられる構造にした。規約は 3 つ。layout は `skills/<name>/SKILL.md` に限る。同名 skill は owner 名の辞書順で先勝ち。submodule を足すことがその repo を信頼する行為で、更新時は diff を見る。旧 `ai/skills/<name>` 直置きとは別物

- 2026-10-02: Windows 実機で確認済み。配布先と同じ経路 (`git clone` → `install.sh`、旧ファイルは `.bak` 退避) と、サブ機の経路 (`git submodule update --init ai/skills/yano3nora` → `copy-configs.sh`) の両方が通った。git bash / PowerShell の `gsheet meta`、`@file` の日本語書き込みも OK

- Codex レビュー (2026-10-02) の指摘と対応
    - P2: `core.autocrlf=true` の Windows で clone すると shell script が CRLF になる。`.gitattributes` で LF 固定にした
    - P2: 配布先 mac の `~/.local/bin` が PATH に無い場合の手順が無い。gsheet の README に確認と追加手順を足した
    - P2: PowerShell → `gsheet.cmd` の経路は `.bashrc` を読まないので mise の shims が PATH に要る。README の PATH 設定に shims を戻した
    - P3: show-me の `open` は macOS 専用。Windows は `start` を併記した

- 2026-10-02: `~/git/yano3nora/skills` は local で `git init` + 初回 commit 済み (submodule 追加に commit が要る)。`.gitmodules` の url は GitHub を指すが、push 前なので `git submodule update` は失敗する。push 後に `git submodule sync` 不要、そのまま使える

- (撤回済み。上の 2026-10-02 の note を参照) chrome-connect は切り出さない。理由: upstream の chrome-devtools-mcp の clone、Node 24、`claude mcp add`、Chrome 側の remote debugging ON、と依存の連鎖が重い。CLI 自体も v1.7.0 の既知の罠が残る「試用中」。配布先の非エンジニアがログイン済み Chrome を Agent に開放するリスクも大きい。bash 化だけなら 1 行だが、周辺が追いついてから考える
- Windows の `~/.local/bin` の PATH 追加は `install.sh` ではやらない。理由: bash から `powershell -Command` を呼ぶと `$env` が bash に展開される事故が既にあった。README の PowerShell 手順に残す
