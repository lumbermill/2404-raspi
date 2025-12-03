#!/usr/bin/env ruby

# センサー値からモーター速度を計算する関数
def calculate_outputs(inputs)
  sensor1, sensor2 = inputs
  motor1 = sensor1 < 30000 ? 1 : 0
  motor2 = sensor2 < 30000 ? 1 : 0
  [motor1, motor2]
end

require 'socket'

server = TCPServer.new 2000 # Server bind to port 2000

loop do
  client = server.accept    # Wait for a client to connect
  client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) # クライアント接続も低遅延化
  
  puts "Client connected: #{client.peeraddr[3]}"
  
  begin
    # クライアントが接続している間、高速ループを継続
    loop do
      # センサー値2つを受信 (例: "100,200\n" の形式を想定)
      data = client.gets
      break if data.nil? # 接続が切れたらループを抜ける
      
      inputs = data.strip.split(',').map(&:to_i)
      
      # センサー値に基づいてモーター速度を計算
      outputs = calculate_outputs(inputs)
      
      # モーター速度2つを返信 (例: "150,180\n" の形式)
      client.puts outputs.join(',')
    end
  rescue => e
    puts "Error: #{e.message}"
  ensure
    client.close
    puts "Client disconnected"
  end
end