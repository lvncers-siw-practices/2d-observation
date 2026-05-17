# おすすめアセット

```text
監視カメラ切り替え
↓
異変探す
↓
来たら対処
↓
ジワジワ怖い
```

系ね。
2Dだとかなり相性いいジャンルだと思う。
しかも実は、「絵が多少シンプルでも成立する」から個人開発向きなんだよね。

## まず相性いいアセット方向

このジャンルは、「リアル」より「監視映像っぽさ」の方が大事。
だから：

* ノイズ
* 暗さ
* 低fps感
* UI
* 音

が超重要。

## おすすめ構成

### 背景

#### pixel art系

* 不気味
* 制作コスト低い
* 雰囲気出る

かなりおすすめ。

## おすすめアセットサイト

### UI・ボタン・監視画面

https://kenney.nl

ここで：

* ボタン
* パネル
* UI
* アイコン

を取る。
監視ゲームってUIめちゃ大事だからかなり相性いい。

## 不気味背景

https://itch.io/game-assets

検索おすすめ：

* horror pixel art
* surveillance
* dark interior
* liminal space
* apartment tileset

## 音が超重要

このジャンル、実は「絵」より音。

### おすすめ

https://freesound.org

検索：

* fluorescent hum
* CCTV static
* air conditioner
* creepy ambience
* footsteps
* elevator ding

## このジャンルで一番強い音

“生活音” なんだよね。
例えば：

* 冷蔵庫
* 換気扇
* 蛍光灯
* 遠くの足音
* 隣人

これだけで怖い。

## かなりおすすめの見た目

### 1. VHS風

最強。
Godot shaderと相性いい。

### 2. アパート監視系

作りやすい。
しかも：

```text
同じ背景
↓
少しだけ違う
```

でゲーム成立する。

### 3. コンビニ・夜勤系

かなり強い。
生活感あると怖さ出る。

## Godotでおすすめ実装

### Scene構成

```text
Main
├─ CameraFeedUI
├─ NoiseOverlay
├─ RoomView
├─ AudioManager
└─ EventManager
```

### 重要なのは「差分」

監視ゲームって：

```text
通常状態
↓
少しだけ異常
```

が本質。
だからアセット大量に作るより、「同じ部屋の差分」を作る。

### 例えば

```text
room_normal.png
room_door_open.png
room_shadow.png
room_no_chair.png
```

みたいに。
これで成立する。

## シェーダー超活躍する

このジャンルはシェーダーと相性神。

### 必須級

#### CRT/VHS

```text
- ノイズ
- 走査線
- 色ズレ
- 圧縮ノイズ
```

#### 点滅

蛍光灯ちらつき

#### wave distortion

監視カメラ乱れ

## Godotで探すなら

https://godotshaders.com

検索：

* crt
* vhs
* glitch
* static
* surveillance

## 個人的に超おすすめアイデア

「異常が怖い」のではなく「正常が崩れる」のを怖くする

これ。
例えば：

* いつもいる人がいない
* 時計が少しズレる
* 椅子の向き違う
* ノイズの奥に顔
* UIが壊れる

とか。
低コストなのにめっちゃ怖い。

## 初心者でも作りやすい理由

このジャンルって：

* AI複雑不要
* マップ巨大不要
* アニメ大量不要

だから、

### 演出特化

できる。
個人開発向き。

## 個人的におすすめの最初の完成形

### 「1部屋だけ」

作る。
例えば：

```text
深夜の監視室
↓
5つのカメラ
↓
異変探し
↓
3日間 survive
```
