# TASK-260908: CursorUIViewService の window リークで WindowServer が重くなる問題の対処

260908 CursorUIViewService の window リークで WindowServer が重くなる問題の対処
===

## asis

- 環境: MacBookPro16,2 (Intel), macOS 26.5.2 (25F84), 外部ディスプレイ 1 枚, 入力ソースは Google 日本語入力 3.34.6260 のみ選択 (有効な入力ソースにキーボードレイアウト ABC 等が 1 つも無い)
- 数日起動しっぱなしにすると WindowServer が 70〜100% CPU で張り付き PC 全体が重くなる
- 原因は `CursorUIViewService` (TextInputUIMacHelper の XPC。macOS 26 の新テキストカーソル横に Caps Lock / 入力モードを表示する機能) が不可視 window を破棄せず溜め続ける Apple 側の既知バグ
    - 2026-09-08 時点で WindowServer 登録 window 5578 枚中 5302 枚が CursorUIViewService 所有だった
    - window は 84x77 (入力モード accessory) と 64x64 の offscreen 不可視 window
- この環境で溜まりが速い引き金はログで特定済み
    - 入力中に数秒おきに `(KeyboardLayouts) no input source available` (fault) が出て、そのたびに `updateCursorAccessories view count` が +3, +2 と増える。減るのはフォーカスが別アプリへ移って view を作り直したときだけ
    - 同時に `-[TUINSInputModeAccessoryView setAccessory:]: -[TUIInputModeAccessory inputMode] should not be nil.` (error) も出ている
    - 頻度は活動時間帯で 150〜500 回/時、view count は 1 時間内で最大 514 まで膨らむ
    - 溜まった状態の古いプロセスは `HIRunLoop ... why is this taking so long?` を毎秒吐く病気状態になっていた
- 溜まった状態で `kill -9 CursorUIViewService` すると WindowServer main thread が 5302 枚の window 破棄 (1 枚ごとに CA transaction commit) で 40 秒以上ブロックされ watchdog に殺される → 強制ログアウト (2026-09-08 14:34 に実際に発生。OS 再起動ではなくセッション終了)

## tobe

- CursorUIViewService の window / view count が入力中に単調増加しない
- 数日起動しっぱなしでも WindowServer の CPU が平常 (数%) を維持する
- 再発時に「何を見れば良いか」が手順化されていて、kill -9 のような巻き添え事故を起こさない

## todo

- [x] 切り分け: メニューバーの入力ソースを Apple 製「日本語 - ローマ字入力」に切り替え 2〜3 分入力し、fault が止まるか確認する (下記 testcases の fault 数コマンド)
    - 結果 (2026-09-08 16:30〜): `no input source available` fault は 0 になったが、view count は fault 無しでも +3, +2 と増え続け、`inputMode should not be nil` も出続けた。**Google IME は主因ではない** (fault のノイズ源なだけ)
- [x] ~~切り分け: Google IME のまま ABC レイアウトを追加して確認する~~ (上の結果から不要。IME に関係なく増えるため)
- [x] 根本封じ: feature flag で新テキストカーソル機能を無効化して再起動する (要 sudo。Caps Lock / 入力モードの吹き出し表示は消える)
    ```
    sudo mkdir -p /Library/Preferences/FeatureFlags/Domain
    sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist redesigned_text_cursor -dict-add Enabled -bool NO
    ```
    戻す場合は `-bool YES` で同じコマンド
    - 結果 (2026-09-08 16:41 再起動後): CursorUIViewService プロセス自体が起動しなくなり、所有 window 0 枚、ログ 0 行。fault / view count の計測対象が消えた
- [x] 適用して効果を確認したら、README の `# MacBook Tuning` に「目的 / コマンド / 戻し方 / 適用日」の形式で追記する (feature flag はファイル書き込みなので再起動・OS アップデートを跨いでも消えない。新 Mac 移行時に手で 1 回打つ)

## testcases

- [x] CursorUIViewService が起動しない (`ps -A | grep CursorUIViewService` が空) — 2026-09-08 確認
- [x] 直近 10 分の fault 数が 0 になる (入力しながら計測する) — プロセスが無いので 0
    ```
    /usr/bin/log show --last 10m --predicate 'process == "CursorUIViewService" AND messageType == fault' | grep -c "no input source"
    ```
- [ ] view count が入力中に増え続けない (最大値が数十で頭打ち)
    ```
    /usr/bin/log show --last 10m --predicate 'process == "CursorUIViewService" AND eventMessage CONTAINS "view count="' | grep -oE "view count=[0-9]+" | sort -t= -k2 -n | tail -1
    ```
- [ ] CursorUIViewService 所有の window 数が 1 日経っても 10 枚前後で安定している (CGWindowListCopyWindowInfo で owner 別に数える)
- [ ] 1〜2 日連続稼働後も WindowServer の CPU が平常

## notes

- feature flag = Apple が OS 内部機能の ON/OFF を切り替えるために持っている隠しスイッチ。`/Library/Preferences/FeatureFlags/Domain/<Framework>.plist` に `機能名 = { Enabled = NO }` を置くと、そのフレームワークが起動時に読んで機能を落とす。ユーザ向け設定 UI は無い。`redesigned_text_cursor` は UIKit 側の新テキストカーソル機能のフラグで、コミュニティで確認された回避策 (https://github.com/Ziqian-Huang0607/-Fix-CursorUIViewService-Memory-Leak-on-macOS-)
- 参考: https://discussions.apple.com/thread/255668660 (cursoruiviewservice Not Responding), https://qiita.com/awa2/items/27ad46dd25341a873040 (WindowServer 占有事例)
- プログラム (TISSelectInputSource) からの入力ソース切替は paramErr (-50) で拒否されるため、切り分けは手動でメニューバーから行う必要がある
- 溜まった状態のプロセスを止めたいときは kill ではなく「保存してログアウト」。WindowServer の後始末コストは避けられないので、意図したタイミングで払う
- 一時しのぎ (再起動不要) が必要なら、window が少ないうちに CursorUIViewService を kill する分にはコストが小さい。目安は所有 window が数百枚以下のとき
- 調査元: 2026-09-08 の PC が重い件の調査 (Claude Code セッション)。ログの stackshot は ~/Downloads/restart.log
