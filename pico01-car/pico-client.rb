# Raspberry Pi Pico用 PicoRubyクライアント
# サーバ: raspi24.local:2000

require 'socket'
require 'machine'

# ピン設定
ANALOG_PIN_1 = 26      # ADC0 (アナログ入力1)
ANALOG_PIN_2 = 27      # ADC1 (アナログ入力2)
OUTPUT_PIN_1 = 16      # モーター1制御用
OUTPUT_PIN_2 = 17      # モーター2制御用

# ピンの初期化
led = GPIO.new("LED", GPIO::OUT)  # Pico W組み込みLED
adc1 = ADC.new(ANALOG_PIN_1)
adc2 = ADC.new(ANALOG_PIN_2)
motor1 = GPIO.new(OUTPUT_PIN_1, GPIO::OUT)
motor2 = GPIO.new(OUTPUT_PIN_2, GPIO::OUT)

# 初期状態
led.write(0)
motor1.write(0)
motor2.write(0)

puts "Connecting to raspi24.local:2000..."

begin
  # サーバに接続
  socket = TCPSocket.new('raspi24.local', 2000)
  
  # 接続成功: LEDを点灯
  led.write(1)
  puts "Connected! LED ON"
  
  # メインループ
  loop do
    # アナログ入力を読み取り (0-65535の16bit値)
    sensor1 = adc1.read_u16
    sensor2 = adc2.read_u16
    
    # サーバに送信
    socket.puts "#{sensor1},#{sensor2}"
    
    # 応答を受信
    response = socket.gets
    if response
      motor1_val, motor2_val = response.strip.split(',').map(&:to_i)
      
      # モーター制御ピンを設定
      motor1.write(motor1_val)
      motor2.write(motor2_val)
      
      # デバッグ出力
      puts "Sensors: #{sensor1}, #{sensor2} -> Motors: #{motor1_val}, #{motor2_val}"
    else
      # 接続が切れた
      puts "Connection lost"
      break
    end
    
    # 短い待機（必要に応じて調整）
    sleep 0.01
  end
  
rescue => e
  # エラー時: LEDを点滅
  puts "Error: #{e.message}"
  10.times do
    led.write(1)
    sleep 0.2
    led.write(0)
    sleep 0.2
  end
ensure
  socket.close if socket
  led.write(0)
  motor1.write(0)
  motor2.write(0)
  puts "Disconnected"
end
