# Raspberry Pi Pico TCP クライアント

Raspberry Pi Picoからraspi24.local:2000のTCPサーバに接続し、アナログセンサー値を送信してモーター制御値を受信します。

## ピン配置

- **LED**: Pico W組み込みLED（接続状態表示）
- **GPIO 26** (ADC0): アナログ入力1
- **GPIO 27** (ADC1): アナログ入力2
- **GPIO 16**: モーター1制御出力
- **GPIO 17**: モーター2制御出力

## 動作

1. サーバ（raspi24.local:2000）に接続
2. 接続成功 → LED点灯 / 失敗 → LED点滅
3. アナログ入力2つを読み取り（0-65535）
4. サーバに送信（例: `"25000,30000\n"`）
5. 応答を受信（例: `"1,0\n"`）
6. GPIO 16, 17をHIGH/LOWに設定
7. ループ継続

## PicoRuby版 (pico-client.rb)

```bash
# Picoにコピーして実行
picorb pico-client.rb
```

## MicroPython版 (pico-client.py)

```bash
# Picoにコピーして実行
mpremote run pico-client.py
# または main.py としてコピーして自動起動
mpremote cp pico-client.py :main.py
```

## 必要な環境

- Raspberry Pi Pico W (WiFi機能付き)
- WiFiネットワークがraspi24.localに接続可能
- サーバ側で `ruby tcp-server.rb` が稼働中

## トラブルシューティング

- **LEDが点滅**: サーバに接続できません。raspi24.localが到達可能か確認してください
- **LEDが点灯したまま応答なし**: サーバは動作していますが、データ送受信に問題があります
- **アナログ値が不安定**: センサーにプルダウン/プルアップ抵抗を追加してください
