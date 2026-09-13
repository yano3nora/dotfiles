# TASK-260912: Apple Silicon (M1) Mac への環境移設

260912 Apple Silicon (M1) Mac への環境移設
===

## asis

- 現行機は Intel (Core i7 / 32GB) / macOS 26.5.2。移設先は型落ちの M1 (16GB)。M1 は次世代機までのつなぎで、メイン機に昇格できるかは未確定
    - そのため **当面は Intel と M1 の 2 台を同じ dotfiles で並行運用する**。Intel を捨てる前提の書き換えはできない
- dotfiles (`dots link` + `mise install`) で再現できる範囲と、手作業でしか再現できない範囲が混在している
- dotfiles 自体に Intel Homebrew 前提 (`/usr/local/...`) のハードコードが残っており、そのままでは M1 で壊れる
    - `zsh/zshrc.d/10-tool.zsh`: GNU grep / php@8.1 の PATH
    - `zsh/zshrc.d/20-zsh.zsh`: `/usr/local/share/powerlevel10k/...`
    - `zsh/zshrc.d/30-alias.zsh`: `alias grep='/usr/local/opt/grep/...'`
    - `mise/config.toml`: `ubi:sharkdp/fd` は darwin/amd64 回避のための指定
    - `mise/README.md`: 「Intel macOS 26 は bottle が無いので mise へ寄せる」という前提で書かれている
- dotfiles 未管理だが shell 起動に必須のものがある
    - `~/.p10k.zsh` (95KB、repo 外)。p10k 本体は brew formula (`powerlevel10k`)
    - `~/.local/zsh/zsh-autosuggestions`, `~/.local/zsh/zsh-syntax-highlighting` (手 clone、README にも clone 手順なし)
    - `~/.zshenv` (cargo / Vite+ の env)、`~/.zprofile` (Docker Desktop の PATH)
- `nvim/` (LazyVim カスタマイズ) は使いこなせず、現在は coda を使っているので持ち越さない
- `bin/mactune` は Intel iGPU の重さ対策 (duetexpertd / HiDPI 切替 / UI プロセス再起動) で、効果が薄かったので廃棄する
- `git/gitconfig` に git-lfs filter があるが、現行機に `git-lfs` は入っていない (設定と実態が乖離)
- macOS 側の手設定が多く、ほぼ記憶に頼っている
    - Symbolic hotkeys: 107 項目中 98 項目を off (Spotlight の cmd+space 含む、Raycast で代替)
    - Spotlight: `mdutil` で index 停止、corespotlight / spotlightknowledged / metadata 系 LaunchAgent を `launchctl disable`
    - Siri: `Assistant Enabled = 0`、Siri.agent / siri*d を disable
    - duetexpertd を disable (Intel の CPU スパイク対策)、CursorUIViewService を feature flag で無効化 (README 記載)
    - Caps Lock → 右 Command の modifier remap (内蔵キーボード単位の設定)
    - Dock / Finder / トラックパッド / メニューバー / スクショ保存先など多数の `defaults`
    - 2026-07-01 時点の退避と復元スクリプトが `~/.mac-tuning-backups/` にある (repo 外)
- アプリは Homebrew cask 管理 (12 個) と手動インストール (約 50 個) が混在
- brew leaves 約 40 個のうち半分以上は過去の build 依存や未使用ツール (automake, bison, openssl@1.1, python@3.11, guile, openvino, httpie など)
- brew tap に古い tap (heroku, browsh, hgrep, fresh など) が残っている
- HOME 直下に旧世代の環境管理ツールが残っている (`.anyenv`, `.nodenv`, `.rbenv`, `.oh-my-zsh`, `.conda`, `.laradock`, `.serverless` など)
- 秘密情報は `~/.ssh` (RSA 鍵)、`~/.aws`, `~/.npmrc` (token)、`~/.netrc`, `~/.config/gh`, `~/.docker`, `~/.claude*`, `~/.codex/auth.json`, `~/.vpn` などに散在
- `/etc/hosts` に project 固有のエントリがある (Vagrant / Docker 由来)

## tobe

- ゴールは「完全復元スクリプト」ではなく **「環境再現設定 + メモ」**。dotfiles 管理物を再整理し、macOS の一般的な設定はコピペで流せるメモとして repo に残す
- Intel / M1 のどちらで clone しても同じ dotfiles が動く (arch 分岐は brew prefix の検出 1 箇所に閉じる)
- 新 Mac の手順が「Brewfile → dotfiles clone → `dots link` → `mise install` → macOS メモを上から適用 → アプリ設定 import」に収まる
- 秘密情報は repo に乗せず、移行手順 (何をどこから持ってくるか) だけを docs に残す
- 使っていない brew formula / tap / 旧環境管理ツール / nvim / mactune / Vagrant 系は新 Mac に持ち込まない
- Intel 固有の対策 (duetexpertd 無効化、CursorUIViewService 無効化) は M1 で症状が出てから適用する

## todo

### Phase 0: 現 Mac での退避 (移設前にやる)

- [x] macOS 設定を plist / テキストで export して `~/backup/mac-migration-260913/` に退避した (2026-09-13。外部ストレージへのコピーは人間判断)
    - `macos/symbolichotkeys.plist` は repo に取り込み済み
    - `defaults read NSGlobalDomain`, `com.apple.dock`, `com.apple.finder`, `com.apple.AppleMultitouchTrackpad`, `com.apple.WindowManager`, `com.apple.menuextra.clock`, `com.apple.controlcenter`, `com.apple.screencapture`, `com.apple.universalaccess`, `com.apple.HIToolbox` を text 保存
    - `launchctl print-disabled gui/$(id -u)` を text 保存
    - `~/.mac-tuning-backups/` を丸ごと退避
- [x] アプリ / CLI の一覧を `~/backup/mac-migration-260913/` に export した
    - `Brewfile.full` (brew bundle dump の生データ)。repo の `Brewfile` は取捨選択済み
    - `ls /Applications` を text 保存
    - `vscode/extensions.txt` は repo に取り込み済み
    - `mise list` を text 保存 (config 外の firebase / rust / zig / 複数 node は project local に寄せる)
- [ ] アプリ個別設定を export する
    - Raycast: Settings → Advanced → Export Settings & Data (`.rayconfig`、パスワード付き暗号化)。拡張 (7 個) / hotkey / snippet / quicklink を含む。token を含みうるので repo には置かず 1Password か外部ストレージへ
    - Rectangle: Settings → Export Config (JSON)
    - BetterDisplay: ライセンス + Settings Export
    - Clipy: `~/Library/Application Support/Clipy`
    - Google 日本語入力: ユーザー辞書を export (`~/Library/Application Support/Google/JapaneseInput/` は DB 形式なのでツールから出す)
    - Ghostty / lazygit / VSCode / leaf / coda は dotfiles 管理済みなので不要
- [ ] 秘密情報の移行方針を決める (repo には絶対に乗せない)
    - `~/.ssh`: RSA 鍵はコピーせず ed25519 で新規発行し GitHub 等へ登録する (現行は `id_rsa` のみ、`config` は空)
    - `~/.aws` (config / credentials / amplify / login), `~/.aws-sam`, `~/.awsp`
    - `~/.npmrc` (npm token)、`~/.netrc` (Heroku)、`~/.config/gh`、`~/.github-label-setup-token`
    - `~/.docker/config.json`、`~/.vpn`、`~/.claude.json` / `~/.claude/settings.json`、`~/.codex/auth.json` / `config.toml`
    - token 類は「コピー」ではなく「再発行」を基本にし、旧機の token は移設後に revoke する
- [x] フォントの棚卸し。必須 3 種は Brewfile の cask に入れた。候補は必要になったら追加する (`fonts.txt` に一覧あり)
    - 必須: MesloLGS NF (VSCode terminal / p10k)、JetBrains Mono Nerd Font (Ghostty)、BIZ UDGothic (Ghostty)。いずれも cask にあるので Brewfile へ
    - 候補: IBM Plex Sans JP, Noto Sans JP, M PLUS 1 Code
    - メイリオ (`meiryo.ttc`) は MS Office 由来なので手動コピーしない
- [x] `/etc/hosts` の project 固有エントリを `~/backup/mac-migration-260913/etc-hosts.txt` に控えた (外部に置かない)

### Phase 1: dotfiles の再整理 (現 Mac で先に直し、Intel でも動くことを確認する)

- [x] **zsh から Homebrew prefix 依存を消す** (B 案)。`10-tool.zsh` の GNU grep / php@8.1 の PATH と `30-alias.zsh` の grep alias を削除。Apple Silicon 用に `/opt/homebrew/bin/brew` があるときだけ `brew shellenv` を eval する 1 箇所だけ残す (mise activate より前)
- [x] php は管理対象から外す (`dots doctor` からも削除)。必要になったら個別に入れる
- [x] **zsh plugin + p10k を git submodule にする** (`zsh/plugins/{powerlevel10k,zsh-autosuggestions,zsh-syntax-highlighting}`)。`20-zsh.zsh` は `$DOTFILES_ROOT/zsh/plugins/...` を source
- [x] `~/.p10k.zsh` を `zsh/p10k.zsh` として取り込み、`bin/dots` の `link_all` に追加 (現行機で link 済み、旧ファイルは `.bak` 退避)
- [x] `~/.zshenv` の cargo / Vite+ env を `10-tool.zsh` の条件付き source に統合。`~/.zprofile` の Docker Desktop 追記はそのまま
- [x] **nvim を廃棄** (`nvim/` 削除、`bin/dots` の link 4 行と doctor の `nvim` 削除、`alias vim=nvim` 削除、README 更新)
- [x] **mactune を廃棄** (`bin/mactune` 削除、`bin/README.md` 更新)。duetexpertd / CursorUIViewService の知見は `macos/README.md` の「症状が出たら適用するもの」に移した
- [ ] `mise/config.toml` の `ubi:sharkdp/fd` を `fd = "latest"` に戻せるか M1 で確認する (Intel は ubi のままなら分岐が要るので、Intel 退役まで触らない)
- [x] `mise/README.md` の Homebrew migration status を Brewfile 前提で書き直し、「prefix を zsh に書かない」ルールを追記
- [x] `git/gitconfig` の git-lfs filter を削除 (未インストール・未使用)
- [x] **`Brewfile` を repo に追加** (formula 10 個 + 設定管理アプリ / フォント / 日常アプリの cask)。cask 名は `brew info --cask` で全件確認済み
- [x] `vscode/extensions.txt` を追加 (33 個)、`vscode/README.md` に install 手順を記載
- [x] **`macos/` を新設** (`macos/README.md` = コピペで流せるメモ、`macos/symbolichotkeys.plist` = 現行機の export)。root README の MacBook Tuning 節は入口に縮小
- [x] `ai/README.md` の Codex 設定例を実際の `~/.codex/config.toml` に合わせて更新
- [x] AGENTS.md に Brewfile / macos / prefix 禁止ルールを追記
- [x] 現行 Intel 機で検証: `zsh -n` 全件 ok、temp HOME で `dots link` 25 link (nvim 0)、実 HOME で `dots link` 冪等、新 shell 起動エラー 0、`dots doctor` all ok、p10k / autosuggestions / highlighting 読み込み確認
- [x] 現行機の後始末: `brew uninstall powerlevel10k`、`~/.local/zsh` 削除、`~/.local/bin/mactune` の dangling symlink 削除 (2026-09-13、削除後も shell 起動エラー 0)。`~/.zshenv` の cargo / Vite+ 行は非対話 shell の PATH に影響しうるので残す
- [x] Codex レビュー (指摘 2 件: `spans-displays` と `ShowDate` の説明文の誤り → 修正済み)
- [ ] commit (人間判断)

### Phase 2: 新 Mac の基盤

- [ ] macOS 初期設定 (Apple ID、FileVault、Touch ID、ローカルアカウント名を `yano3` に揃える。HOME パスが変わると `.zprofile` / Codex `config.toml` の絶対パスが壊れる)
- [ ] Xcode Command Line Tools: `xcode-select --install`
- [ ] Rosetta 2: `softwareupdate --install-rosetta --agree-to-license` (Intel 専用アプリ / x86 の npm native module 用)
- [ ] Homebrew (`/opt/homebrew`) を入れる
- [ ] mise を入れる (`curl https://mise.run | sh` → `~/.local/bin/mise`)
- [ ] 1Password を入れて、SSH 鍵 / token / Raycast export の受け渡し経路を先に確保する
- [ ] Git 用の ed25519 鍵を作成し GitHub に登録する
- [ ] dotfiles を clone する: `git clone --recurse-submodules git@github.com:yano3nora/dotfiles.git ~/git/yano3nora/dotfiles`

### Phase 3: 開発環境 (dotfiles 適用)

- [ ] `brew bundle --file=Brewfile` (アプリと font を先に入れる。設定 dir の親は `dots link` が作るので順序は厳密でなくてよい)
- [ ] `HOME=/private/tmp/dots-test ./bin/dots link` で dry run してから `./bin/dots link` を実行する
- [ ] `mise install` → `mise doctor`
- [ ] `dots doctor` が all ok になるまで欠けを埋める (convmv / zip / ffmpeg / trash は Brewfile、code は cask)
- [ ] 新 shell を開き、p10k が `~/.cache/gitstatus/` に arm64 の gitstatusd を取得することを確認する
- [ ] Docker Desktop を起動して `~/.docker/run/docker.sock` ができることを確認する (`10-tool.zsh` の `DOCKER_HOST`)。VM のメモリ割当は現行の 2GB / 1CPU を上限の目安にする (M1 16GB では増やしすぎない)
- [ ] VSCode: `dots link` 済みの settings / keybindings に加え `vscode/extensions.txt` から拡張を入れる
- [ ] Claude Code: native install (`~/.local/bin/claude`) → `ai/README.md` の plugin 手順 (ponytail / chrome-devtools-mcp の local marketplace) を再現する。`~/.claude/settings.json` は旧機から手動で持ってくる
- [ ] Codex CLI: `brew install --cask codex` → `ai/README.md` の `config.toml` 手動項目を設定する
- [ ] Vite+ (`~/.vite-plus`)、rustup (`~/.cargo`)、uv / pdm は必要になった時点で入れる (先回りしない)
- [ ] `~/git` は何も持ち越さない。必要になった repo をその都度 clone する
- [ ] 持ち込まないもの: `~/.anyenv`, `~/.nodenv`, `~/.rbenv`, `~/.oh-my-zsh`, `~/.conda` / Anaconda, `~/.laradock`, `~/.serverless`, `~/.composer`, `~/.gem`, `~/.mono` / `.dotnet` / `.nuget`, `~/.vagrant.d`, `~/.config/nvim`

### Phase 4: macOS 設定 (`macos/README.md` を上から流す)

- [ ] キーボードショートカット: `defaults import com.apple.symbolichotkeys macos/symbolichotkeys.plist` → ログアウト。効かない場合は「システム設定 → キーボード → キーボードショートカット」で手動確認
- [ ] Caps Lock → 右 Command: 内蔵キーボードの product ID が M1 で変わるので、システム設定 → キーボード → 修飾キー で手動再設定 (`defaults` では持ち越せない)
- [ ] 入力ソース: Google 日本語入力 (ローマ字) + Kotoeri を並べ、ユーザー辞書を import する
- [ ] Spotlight 停止: `sudo mdutil -a -i off` + Spotlight 系 LaunchAgent の disable (corespotlightd / corespotlightservice / managedcorespotlightd / spotlightknowledged{,.updater,.importer} / metadata.md{write,bulkimport,flagwriter}) → 再起動。Raycast を cmd+space に割り当てる
- [ ] Siri 停止: システム設定で Siri off + `Siri.agent` / `siriactionsd` / `siriknowledged` / `siriinferenced` / `sirittsd` を disable
- [ ] その他 disable: `FolderActionsDispatcher`, `ScriptMenuApp`, `ManagedClientAgent.enrollagent`, `appleseed.seedusaged.postinstall`
- [ ] duetexpertd / CursorUIViewService: **適用しない**。M1 で WindowServer や CPU の異常が出た時だけ README のメモを見て適用する
- [ ] NSGlobalDomain (外観・入力): Dark モード / `AppleKeyboardUIMode=2` / `AppleShowAllExtensions=1` / `NSAutomatic*=0` (自動大文字・スペル修正・スマート引用符・ダッシュ・ピリオド・インライン予測・補完すべて off) / `AppleReduceDesktopTinting=1` / `AppleShowScrollBars=WhenScrolling` / `NSQuitAlwaysKeepsWindows=1` / `AppleSpacesSwitchOnActivate=0` / `AppleMiniaturizeOnDoubleClick=0` / `com.apple.springing.enabled=0` / `com.apple.trackpad.forceClick=0` / トラックパッド速度 `0.875` / マウス速度 `3` / locale `ja_JP`
- [ ] Dock: 自動的に隠す / `tilesize=61` / 拡大 off / 最近使ったアプリ off / `mru-spaces=0` / `launchanim=0` / `expose-group-apps=0` / ホットコーナーなし / デスクトップ表示ジェスチャ off
- [ ] Mission Control: `spans-displays=1` (操作スペースを全ディスプレイにまたがせる。「ディスプレイごとに個別の操作スペース」は off)
- [ ] Finder: 隠しファイル表示 / リスト表示 / 検索は現在のフォルダ / 新規ウィンドウはホーム / Finder 終了メニュー / パスバー表示 / ステータスバー非表示 / デスクトップにディスクを表示しない / 最近使ったタグ非表示
- [ ] デスクトップとステージマネージャ: デスクトップをクリックして表示 off / 端へドラッグでタイル off / デスクトップアイコン非表示 / ウィジェット非表示
- [ ] トラックパッド: タップでクリック off / 3 本指ドラッグ off / 強めのクリック off / 副ボタン (2 本指) on / 3・4 本指スワイプ on / 5 本指ピンチ off
- [ ] アクセシビリティ: 透明度を下げる on / ポインタサイズ約 1.5
- [ ] メニューバー: 時計 24 時間 + 秒 + 曜日、日付は空きがあれば表示 (`ShowDate=0`) / コントロールセンターは Battery, Bluetooth, WiFi, Clock のみ表示 / Siri と Spotlight のメニュー項目 off
- [ ] スクリーンショット: 保存先 `~/Downloads`、ファイル名 `capture`、選択範囲、カーソル表示
- [ ] 電源: `sudo pmset -a displaysleep 0 powernap 0` (現行と同じ。M1 の電池持ちを見て見直す)
- [ ] デフォルトブラウザを Chrome にする
- [ ] `/etc/hosts` は必要な project 分だけ手で追加する

### Phase 5: アプリ設定の import

- [ ] Raycast: 初回起動 → Settings → Advanced → Import で `.rayconfig` を読む → cmd+space の hotkey と拡張が戻っていることを確認
- [ ] Rectangle / BetterDisplay / Clipy に Phase 0 の export を import する
- [ ] Google 日本語入力にユーザー辞書を import する
- [ ] cask 化できない / ストア経由のものは必要になった時点で入れる: Kindle, LINE, Keynote / Numbers / Pages, Klack, RunCatNeo, ImageOptim, Lepton, LadioCast, Elgato Wave Link, voicepeak, Easy CSV Editor, Vivaldi, Microsoft Office / Teams, Webex, zoom, ovice, AWS VPN Client, eTax, Audacity
- [ ] 持ち込まないもの: VirtualBox / Vagrant (使っていない)、Macs Fan Control (M1 で不要)、Authy Desktop (開発終了、TOTP は 1Password へ)、Anaconda、Adobe XD (終了)、GitHub Desktop (lazygit で足りる)、Unity / Visual Studio / Steam / Battle.net / Minecraft (必要な時に)

### Phase 6: 検証と撤収

- [ ] 下記 testcases を Intel / M1 の両方で通す (Intel は Phase 1 直後、M1 は Phase 5 まで終わってから)
- [ ] 旧 Mac で発行していた token (npm / GitHub / gh / Heroku / AWS) を M1 で再発行できたら revoke する
- [ ] `~/.mac-tuning-backups/` の内容が `macos/README.md` で再現できていることを確認する
- [ ] Intel を手放す時は、`~/git` の未 push ブランチ・`~/Downloads`・`~/.ssh` の残骸が無いか最終確認する
- [ ] この docs の完了項目にチェックを付け、`macos/README.md` に「M1 で検証済み」の適用日を書く

## testcases

- [ ] (M1) `uname -m` が `arm64`、`file "$(mise which jq)"` が arm64 バイナリを指す (Rosetta 経由で動いていない)
- [x] (Intel) / [ ] (M1) `zsh -n bin/dots` / `zsh -n zsh/zshrc` / `for f in zsh/zshrc.d/*.zsh; do zsh -n "$f" || break; done` が通る
- [x] (Intel) 新しい shell を開いてエラー / p10k instant prompt の WARNING が出ない。プロンプトが p10k で描画される
- [ ] (M1) 同上。`echo $HOMEBREW_PREFIX` が `/opt/homebrew`、`which trash` が `/opt/homebrew/bin/trash`
- [x] (Intel) / [ ] (M1) `HOME=/private/tmp/dots-test ./bin/dots link` が全 link を作成し、実 HOME でも `already linked` で冪等になる
- [x] (Intel) / [ ] (M1) `dots doctor` が all ok
- [ ] (両方) `mise doctor` に問題なし。`which node jq rg fd fzf gh bat direnv lazygit coda leaf` が全部 `~/.local/share/mise/` 配下
- [ ] (M1) `ssh -T git@github.com` が通り、`git commit` の author が想定通り
- [ ] (M1) `docker ps` が動く (`DOCKER_HOST` の socket path が正しい)
- [ ] (M1) Ghostty で JetBrains Mono + BIZ UDGothic が表示される。VSCode terminal で MesloLGS NF のアイコンが崩れない
- [ ] (M1) VSCode の settings / keybindings が symlink で、拡張が `vscode/extensions.txt` と一致する
- [ ] (M1) cmd+space で Spotlight ではなく Raycast が開く。`mdutil -s /` が `Indexing disabled`
- [ ] (M1) `launchctl print-disabled gui/$(id -u)` に Phase 4 の項目が並ぶ
- [ ] (M1) Caps Lock が右 Command として動く (Google 日本語入力の英数 / かな切替が現行通り)
- [ ] (M1) `defaults read com.apple.dock autohide` など Phase 4 の代表値が現行と一致する
- [ ] (M1) `claude` / `codex` が起動し、`~/.claude/CLAUDE.md` / `~/.codex/instructions.md` が repo の `ai/CLAUDE.md` を指す

## notes

- 調査日: 2026-09-12。現行機は Intel Core i7 / 32GB / macOS 26.5.2 (25F84)。Docker Desktop の VM 割当は 2GB / 1CPU
- 決定事項 (2026-09-12 / 09-13)
    - Intel と M1 を当面並行運用する。dotfiles は両 arch で動くようにし、Intel 切り捨ての書き換えはしない
    - brew prefix 対応は B 案 (zsh から brew 依存を消す)。php は管理せず必要時に個別に入れる。GNU grep も外す (scripts に GNU 依存なし)
    - p10k は継続。plugin 込みで git submodule 化する
    - Raycast の export は人間が GUI から出して 1Password 等に置く
    - nvim / LazyVim は廃棄 (coda を使う。vim を使うなら plain vim)
    - mactune は廃棄。知見は README のメモに残す
    - Docker Desktop は維持
    - Vagrant / VirtualBox 依存 project は無視
    - `~/git` は何も持ち越さない
    - ゴールは完全復元スクリプトではなく「環境再現設定 + メモ」
- brew prefix 対応の選択肢と判断
    - A. `brew shellenv` で prefix を検出して `$HOMEBREW_PREFIX/opt/...` を使う: 分岐 1 箇所で両 arch 対応できるが、brew 依存が zsh に残り続ける
    - B. brew 依存 (grep / php / p10k) を zsh から消す (採用): p10k は submodule、grep は BSD grep で足りる (scripts に GNU 依存なし)、php はそもそも使っていない。Apple Silicon の `/opt/homebrew/bin` を PATH に通すための `brew shellenv` 1 行だけ残す
    - C. M1 の `/opt/homebrew` に書き換えて Intel を捨てる: 並行運用と矛盾するので不採用
- zsh plugin の選択肢と判断
    - 手 clone (現状): README にすら手順が無く再現性ゼロ
    - brew (p10k のみ現状): arch ごとに path が変わる、plugin 2 つは brew に無い
    - plugin manager (zinit / antidote 等): 新しい依存が増える。3 つしか使わないので過剰
    - git submodule (採用): 純 zsh script なので arch 非依存、clone 一発、version も固定される。更新は `git submodule update --remote` を年に数回で十分
    - p10k は 2024 年以降 maintenance mode だが動作に支障はない。壊れたら starship 等へ乗り換える (今回は対象外)
- Symbolic hotkeys で on のまま残っている 9 項目: 55, 56, 62, 63, 70, 73, 156, 164, 184。plist ごと import すれば個別の意味を追う必要はない
- 修飾キー remap は `com.apple.keyboard.modifiermapping.1452-638-0` (Apple 内蔵キーボードの vendor-product ID)。M1 は product ID が変わるので `defaults` の持ち越しは不可
- Spotlight / Siri 系の disable は 2026-07-01 に実施。復元手順は `~/.mac-tuning-backups/restore-spotlight-siri-shortcuts.sh` にある。これを `macos/README.md` の元ネタにする
- `~/.mac-tuning-backups/restore-vscode-gpu.sh` は VSCode の `argv.json` (`disable-hardware-acceleration`) 用。現行は `false` に戻っているので M1 では不要
- duetexpertd / CursorUIViewService / Macs Fan Control / BetterDisplay の HiDPI 切替はいずれも「Intel iGPU + HiDPI 外部ディスプレイで重い」問題への対処。M1 では前提が変わるので、症状が出てから適用する
- Homebrew は M1 なら bottle があるので、brew → mise の移行 (`docs/TASK-260707-brew-to-mise-cleanup.md`) の動機の半分は消える。ただし「global CLI の入口を `mise/config.toml` に揃える」方針自体は維持し、brew は build / OS 依存の例外に限定する
- `brew leaves` に残っている build 依存 (automake, bison, re2c, guile, openvino など) は過去に何かを source build した名残。Brewfile には入れない
- `~/.ssh/config` は空、鍵は `id_rsa` のみ。移設を機に ed25519 へ更新し、1Password SSH agent を使うかも検討する
- Codex の `~/.codex/config.toml` には project ごとの trust 設定 (絶対パス) が書き戻されるため repo 管理しない。手動維持する項目は `ai/README.md` 参照
- `/etc/hosts` の project 固有エントリ、仕事用 org の repo 名、token 類はこの docs にも書かない
- 16GB について: 現行の使い方 (Docker VM 2GB + VSCode + Chrome + Claude Code) なら M1 のメモリ効率で足りる見込み。Docker の割当を増やさない、Chrome のタブを溜めない、の 2 点で様子を見る
