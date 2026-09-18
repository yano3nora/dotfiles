# macOS

## Overview

symlink やコマンドで管理できない、macOS 側の設定のメモ。
新しい Mac に移るときは上から順にコピペで流す。完全な復元 script ではなく「環境再現設定 + メモ」として維持する。

Managed files:

- `README.md` - このメモ
- `symbolichotkeys.plist` - キーボードショートカットの export (`defaults export com.apple.symbolichotkeys -`)

項目ごとに「目的 / コマンド / 戻し方 / 適用日」を書く。GUI でしか設定できないものは GUI の場所を書く。

## Getting Started

```sh
# 1. defaults を流す (下記 Settings をそのままコピペ)
# 2. ショートカットを import する
defaults import com.apple.symbolichotkeys macos/symbolichotkeys.plist
# 3. Spotlight / Siri を止める (下記 Spotlight / Siri)
# 4. ログアウト → ログイン (defaults の反映) / 再起動 (launchctl の反映)
```

`defaults write` は cfprefsd がキャッシュを持つため、GUI のシステム設定を開いたまま流すと上書きされることがある。システム設定を閉じてから流す。

## Settings

### 外観・入力 (NSGlobalDomain)

```sh
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
defaults write NSGlobalDomain AppleLocale -string ja_JP
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2               # Tab でフォーカス移動を全コントロールに
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain AppleShowScrollBars -string WhenScrolling
defaults write NSGlobalDomain AppleReduceDesktopTinting -bool true
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool false
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
# 自動修正系は全部 off (コードや英日混在の入力を勝手に変えさせない)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false
# トラックパッド / マウス
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
defaults write NSGlobalDomain com.apple.springing.enabled -bool false
```

### トラックパッド

```sh
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false                 # タップでクリック off
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true          # 2 本指で副ボタン
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 0
```

### Dock / Mission Control

```sh
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 61
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false          # 最近の使用状況で操作スペースを並べ替えない
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-group-apps -bool false
defaults write com.apple.dock showDesktopGestureEnabled -bool false
defaults write com.apple.dock wvous-br-corner -int 1          # ホットコーナーなし (1 = no-op)
defaults write com.apple.spaces spans-displays -bool true     # 操作スペースを全ディスプレイにまたがせる (「ディスプレイごとに個別の操作スペース」off)
killall Dock
```

### Finder / デスクトップ

```sh
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv        # リスト表示
defaults write com.apple.finder FXDefaultSearchScope -string SCcf        # 検索は現在のフォルダ
defaults write com.apple.finder NewWindowTarget -string PfHm             # 新規ウィンドウはホーム
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder ShowRecentTags -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# デスクトップとステージマネージャ
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager HideDesktop -bool true
killall Finder
```

### メニューバー / アクセシビリティ / スクリーンショット

```sh
# 時計: 24 時間 + 秒 + 曜日、日付は空きがあれば表示 (ShowDate: 0 = 空きがあれば, 1 = 常に, 2 = しない)
defaults write com.apple.menuextra.clock Show24Hour -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
# コントロールセンターの常時表示は Battery / Bluetooth / WiFi / Clock のみ。Siri / Spotlight は GUI で off にする
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true
# アクセシビリティ (透明度を下げる / ポインタサイズは GUI の方が確実)
defaults write com.apple.universalaccess reduceTransparency -bool true
# スクリーンショット: ~/Downloads に capture*.png、選択範囲、カーソル込み
defaults write com.apple.screencapture location -string "$HOME/Downloads"
defaults write com.apple.screencapture name -string capture
defaults write com.apple.screencapture style -string selection
defaults write com.apple.screencapture showsCursor -bool true
killall SystemUIServer
```

### 電源

```sh
sudo pmset -a displaysleep 0 powernap 0
```

- 戻し方: `sudo pmset -a displaysleep 10 powernap 1`
- Apple Silicon の電池持ちを見て見直す

### キーボードショートカット

- 目的: macOS 標準のショートカット 107 項目のうち 98 項目を off にする (Spotlight の cmd+space は Raycast に譲る、Mission Control や入力ソース切替などアプリの keybind と衝突するものを消す)
- コマンド:
    ```sh
    defaults import com.apple.symbolichotkeys macos/symbolichotkeys.plist
    ```
    その後ログアウト → ログイン。効かない場合は システム設定 → キーボード → キーボードショートカット で「デフォルトに戻す」から手で off にする
- 戻し方: システム設定 → キーボード → キーボードショートカット → デフォルトに戻す
- 更新: 現行機で変えたら `defaults export com.apple.symbolichotkeys - > macos/symbolichotkeys.plist`

### GUI でしか設定できないもの

- 修飾キー: Caps Lock → 右 Command (システム設定 → キーボード → キーボードショートカット → 修飾キー)。キーボードごとの設定なので `defaults` では持ち越せない
- 入力ソース: Google 日本語入力 (ローマ字) + 日本語 IM (ローマ字)。ユーザー辞書は Google 日本語入力の環境設定 → 辞書 から export / import
- Siri: システム設定 → Apple Intelligence と Siri → off。メニューバーの Siri / Spotlight アイコンもここで off
- アクセシビリティ → ディスプレイ → ポインタのサイズ: 約 1.5
- デフォルトブラウザ: Google Chrome
- Raycast: cmd+space を hotkey にする。設定は Settings → Advanced → Export / Import (`.rayconfig`、暗号化されるので 1Password などに保管、repo には置かない)
- Rectangle: Settings → Export / Import Config
- `/etc/hosts`: project 固有のエントリは必要な project 分だけ手で追加する

## Spotlight / Siri

- 目的: Spotlight の index (mds / corespotlight) と Siri の学習 daemon を止めて、バックグラウンド CPU / ディスク I/O を消す。検索は Raycast で足りる
- 代償: Spotlight 検索と、Spotlight index に依存する Finder 検索・メールの検索が効かなくなる
- コマンド (要再起動):
    ```sh
    sudo mdutil -a -i off
    for s in \
      com.apple.corespotlightd com.apple.corespotlightservice com.apple.managedcorespotlightd \
      com.apple.spotlightknowledged com.apple.spotlightknowledged.updater com.apple.spotlightknowledged.importer \
      com.apple.metadata.mdwrite com.apple.metadata.mdbulkimport com.apple.metadata.mdflagwriter \
      com.apple.Siri.agent com.apple.siriactionsd com.apple.siriknowledged com.apple.siriinferenced com.apple.sirittsd \
      com.apple.FolderActionsDispatcher com.apple.ScriptMenuApp \
      com.apple.ManagedClientAgent.enrollagent com.apple.appleseed.seedusaged.postinstall; do
      launchctl disable "gui/$(id -u)/$s"
    done
    ```
- 確認: `mdutil -s /` が `Indexing disabled.`、`launchctl print-disabled gui/$(id -u)` に上記が並ぶ
- 定期確認: `dots doctor` が `mdutil -s -a` で全ボリュームを見る。OS 更新後と外部ディスクを挿した後に流す
- 戻し方: 同じ list を `launchctl enable` し、`sudo mdutil -a -i on` → 再起動
- 注意: OS アップデートで disabled 登録が戻ることがある。不調時はまず `launchctl print-disabled` を確認する
- 適用日: 2026-07-01 (Intel / macOS 26.5) / 2026-09-13 (M1。Spotlight 系 agent のみ適用、Siri 系は GUI off に留めて launchctl disable は未適用)

## 症状が出たら適用するもの

いずれも Intel (iGPU + HiDPI 外部ディスプレイ) で重かった時の対処。Apple Silicon では前提が変わるので、先回りせず症状が出てから適用する。

### duetexpertd の無効化

- 症状: `duetexpertd` (Siri 提案などのバッチ学習 daemon) が CPU を占有してマシンが長時間使い物にならない
- コマンド:
    ```sh
    launchctl disable "gui/$(id -u)/com.apple.duetexpertd"
    launchctl bootout "gui/$(id -u)/com.apple.duetexpertd"
    ```
- 確認: `launchctl print-disabled gui/$(id -u) | grep duetexpertd`
- 戻し方: `launchctl enable "gui/$(id -u)/com.apple.duetexpertd"` → 再起動
- 適用日: 2026-07-07 (Intel)

### 新テキストカーソル機能 (CursorUIViewService) の無効化

- 症状: macOS 26 でカーソル横の Caps Lock / 入力モード表示を担う `CursorUIViewService` が不可視 window を破棄せず溜め続け、数日で WindowServer が CPU 100% になる (経緯は [`docs/TASK-260908-cursoruiviewservice-leak.md`](../docs/TASK-260908-cursoruiviewservice-leak.md))
- 代償: Caps Lock / 入力モードの吹き出し表示が出なくなる
- コマンド (要再起動):
    ```sh
    sudo mkdir -p /Library/Preferences/FeatureFlags/Domain
    sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist redesigned_text_cursor -dict-add Enabled -bool NO
    ```
- 戻し方: 同じコマンドを `-bool YES` で実行して再起動
- 確認: `ps -A | grep CursorUIViewService` に何も出なければ効いている
- 適用日: 2026-09-08 (Intel / macOS 26.5.2)

## Trouble Shooting

`defaults write` が反映されない:

```sh
killall cfprefsd   # キャッシュを捨てる
# それでも駄目ならログアウト → ログイン
```

`defaults import` した hotkey が効かない:

```sh
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -c "enabled = 0"   # 98 なら import 自体は成功
# システム設定 → キーボード → キーボードショートカット を一度開いて閉じる (cfprefsd に読み直させる)
```

## My Recommendation

設定を変えたら、その場でこの README に「目的 / コマンド / 戻し方 / 適用日」を書く。あとで思い出せないものは記憶に頼らず、`defaults read <domain>` で差分を取って追記する。
