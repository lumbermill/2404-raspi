require 'socket'

# サーバを別スレッドで起動
server_thread = Thread.new do
  load './tcp-server.rb'
end

# サーバの起動を少し待つ
sleep 1

puts "=== TCP Server Test ==="
puts "Connecting to server..."

begin
  # サーバに接続
  client = TCPSocket.new('localhost', 2000)
  client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  
  puts "Connected successfully!\n\n"
  
  # テストケースを実行
  test_cases = [
    [25000, 25000],  # 両方のセンサー値が30000未満 → [1, 1]
    [35000, 25000],  # sensor1のみ30000以上 → [0, 1]
    [25000, 35000],  # sensor2のみ30000以上 → [1, 0]
    [35000, 35000],  # 両方のセンサー値が30000以上 → [0, 0]
    [30000, 30000],  # 境界値テスト → [0, 0]
    [29999, 29999],  # 境界値テスト → [1, 1]
  ]
  
  test_cases.each_with_index do |(sensor1, sensor2), i|
    # センサー値を送信
    client.puts "#{sensor1},#{sensor2}"
    
    # モーター速度を受信
    response = client.gets
    motor1, motor2 = response.strip.split(',').map(&:to_i)
    
    # 結果を表示
    puts "Test #{i + 1}:"
    puts "  Input:  sensor1=#{sensor1}, sensor2=#{sensor2}"
    puts "  Output: motor1=#{motor1}, motor2=#{motor2}"
    puts
    
    # 少し間隔を空ける（オプション）
    sleep 0.1
  end
  
  # 連続送信のパフォーマンステスト
  puts "=== Performance Test ==="
  puts "Sending 100 requests..."
  
  start_time = Time.now
  100.times do |i|
    client.puts "#{25000 + i * 100},#{25000 + i * 100}"
    response = client.gets
  end
  elapsed = Time.now - start_time
  
  puts "Completed 100 requests in #{elapsed.round(3)} seconds"
  puts "Average: #{(elapsed / 100 * 1000).round(2)} ms per request"
  puts "Throughput: #{(100 / elapsed).round(1)} requests/sec"
  
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
ensure
  client.close if client
  puts "\n=== Test completed ==="
  puts "Press Ctrl+C to stop the server"
end

# メインスレッドでサーバスレッドの終了を待つ
server_thread.join
