# line-trace.rb
# ライントレースカー for Raspberry Pi Pico W
# IchgoJam BASIC版: https://lmlab.net/posts/2026/2026-05-06-ichigo-car-rev3-6.html

# Pico W 組み込みLED
# Pico (無印) の場合: led = GPIO.new(25, GPIO::OUT)
CYW43.init
led = CYW43::GPIO.new(CYW43::GPIO::LED_PIN)
led.write(1)
sleep 1
led.write 0

# センサー (IchgoJam: ANA(0)=右センサーR, ANA(2)=左センサーL)
adc_r = ADC.new(26)  # GPIO26 = ADC0
adc_l = ADC.new(27)  # GPIO27 = ADC1
puts "ADC initialized"

# モーター制御ピン (Hブリッジ)
# 前進: a1=1,a2=0 / 後退: a1=0,a2=1 / 停止: a1=0,a2=0
motor_a1 = GPIO.new(14, GPIO::OUT)  # IchgoJam OUT2 相当 (モーターA 前進)
motor_a2 = GPIO.new(15, GPIO::OUT)  # IchgoJam OUT1 相当 (モーターA 後退)
motor_b1 = GPIO.new(17, GPIO::OUT)  # IchgoJam OUT5 相当 (モーターB 前進)
motor_b2 = GPIO.new(16, GPIO::OUT)  # IchgoJam OUT6 相当 (モーターB 後退)
motor_a1.write(0); motor_a2.write(0)
motor_b1.write(0); motor_b2.write(0)
puts "GPIO initialized"

# 起動完了 → 点灯維持
led.write(1)
puts "Start"

# センサー閾値: IchgoJam は0-1023で閾値500、Pico ADC#read は0-65535
THRESHOLD = 50000

loop do
  # センサー読み取り (IchgoJam 50行: R=ANA(0):L=ANA(2))
  r = adc_r.read
  l = adc_l.read
  # puts "R=#{r} L=#{l}"

  # 両端が白いエリア → Uターンシーケンス (IchgoJam 60行: IF R<500 AND L<500 GOTO110)
  if false && r < THRESHOLD && l < THRESHOLD
    puts "U-turn start"

    # 直進 (IchgoJam 110-120行: OUT2,1:OUT5,1 / WAIT120)
    motor_a1.write(1); motor_a2.write(0)
    motor_b1.write(1); motor_b2.write(0)
    puts "forward"
    sleep 2.0

    # 停止 (IchgoJam 130-140行: OUT2,0:OUT5,0 / WAIT120)
    motor_a1.write(0); motor_a2.write(0)
    motor_b1.write(0); motor_b2.write(0)
    puts "stop"
    sleep 2.0

    # 旋回: モーターA前進 + モーターB後退 (IchgoJam 150-160行: OUT2,1:OUT5,0:OUT6,1 / WAIT110)
    motor_a1.write(1); motor_a2.write(0)
    motor_b1.write(0); motor_b2.write(1)
    puts "turn"
    sleep 1.83

    # 直進再開 (IchgoJam 170-180行: OUT2,1:OUT5,1 / WAIT120)
    motor_a1.write(1); motor_a2.write(0)
    motor_b1.write(1); motor_b2.write(0)
    puts "forward"
    sleep 2.0

    next
  end

  # ライントレース (IchgoJam 70-80行)
  # IF L>500 OUT2,1 ELSE OUT2,0
  if l < THRESHOLD
    motor_a1.write(1); motor_a2.write(0)
  else
    motor_a1.write(0); motor_a2.write(0)
  end
  # IF R>500 OUT5,1 ELSE OUT5,0
  if r < THRESHOLD
    motor_b1.write(1); motor_b2.write(0)
  else
    motor_b1.write(0); motor_b2.write(0)
  end

  # puts "A=#{l > THRESHOLD ? 1 : 0} B=#{r > THRESHOLD ? 1 : 0}"
  sleep 0.20  # IchgoJam WAIT10 = 10/60秒
end
