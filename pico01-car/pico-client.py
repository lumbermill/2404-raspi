# Raspberry Pi Pico用 MicroPythonクライアント
# サーバ: raspi24.local:2000

import socket
import time
from machine import Pin, ADC

# ピン設定
ANALOG_PIN_1 = 26      # ADC0 (アナログ入力1)
ANALOG_PIN_2 = 27      # ADC1 (アナログ入力2)
OUTPUT_PIN_1 = 16      # モーター1制御用
OUTPUT_PIN_2 = 17      # モーター2制御用

# ピンの初期化
led = Pin("LED", Pin.OUT)  # Pico W組み込みLED
adc1 = ADC(Pin(ANALOG_PIN_1))
adc2 = ADC(Pin(ANALOG_PIN_2))
motor1 = Pin(OUTPUT_PIN_1, Pin.OUT)
motor2 = Pin(OUTPUT_PIN_2, Pin.OUT)

# 初期状態
led.value(0)
motor1.value(0)
motor2.value(0)

print("Connecting to raspi24.local:2000...")

try:
    # サーバに接続
    sock = socket.socket()
    sock.connect(socket.getaddrinfo('raspi24.local', 2000)[0][-1])
    
    # 接続成功: LEDを点灯
    led.value(1)
    print("Connected! LED ON")
    
    # メインループ
    while True:
        # アナログ入力を読み取り (0-65535の16bit値)
        sensor1 = adc1.read_u16()
        sensor2 = adc2.read_u16()
        
        # サーバに送信
        message = f"{sensor1},{sensor2}\n"
        sock.send(message.encode())
        
        # 応答を受信
        response = sock.recv(128).decode().strip()
        if response:
            motor1_val, motor2_val = map(int, response.split(','))
            
            # モーター制御ピンを設定
            motor1.value(motor1_val)
            motor2.value(motor2_val)
            
            # デバッグ出力
            print(f"Sensors: {sensor1}, {sensor2} -> Motors: {motor1_val}, {motor2_val}")
        else:
            # 接続が切れた
            print("Connection lost")
            break
        
        # 短い待機（必要に応じて調整）
        time.sleep(0.01)

except Exception as e:
    # エラー時: LEDを点滅
    print(f"Error: {e}")
    for _ in range(10):
        led.value(1)
        time.sleep(0.2)
        led.value(0)
        time.sleep(0.2)

finally:
    sock.close()
    led.value(0)
    motor1.value(0)
    motor2.value(0)
    print("Disconnected")
