# Raspberry Pi Pico ライントレースカー

Raspberry Pi Pico Wで、白い線の上をトレースするラジコンのコードです。Picoでも動作しますが、LEDの点灯方法が異なります。

参考: [IchogoJam BASIC版](https://lmlab.net/posts/2026/2026-05-06-ichigo-car-rev3-6.html)

## ピン配置

- **LED**: Pico W組み込みLED（接続状態表示）
- **GPIO 26** (ADC0): アナログ入力1
- **GPIO 27** (ADC1): アナログ入力2
- **GPIO 16**: モーター1制御出力
- **GPIO 17**: モーター2制御出力

## 動作

1. 起動完了 → LED点灯
2. アナログ入力2つを読み取り（0-65535）
3. GPIO 16, 17をHIGH/LOWに設定
4. 両端が白いエリアについたらUターン(隣のコースに入るため340度くらい回る)
5. 2~3に戻る

## インストール

```
prremote deploy line-trace.rb
```
