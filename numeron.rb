module Numeron
  def initialize()
    @@data = Hash.new
    @@data.default = 0
  end

  def generate(status,n) #4桁の被らない数字を生成
    username = status.user.screen_name
    if @@data[username].is_a?(Time)
      return 0 if @@data[username] > Time.now
    end
    num = ""
    puts "nande"
    n.times do
      if n == 4
        i = rand(0..9).to_s
      else
        i = rand(0..15).to_s(16)
      end
      repeat = 0
      num.each_char do |c|
       repeat = 1 if c == i
      end
      redo if repeat == 1
      num += i
    end
    puts num
    @@data[username] = Hash.new
    @@data[username]["answer"] = num
    @@data[username]["count"] = 0
    @@data[username]["time"] = Time.now.to_i
    puts @@data
    $client.update("@#{username} 開始しました",:in_reply_to_status_id => status.id)
  end

  def judge(status)
    reply = status.text.gsub(/@_ke_bot_|\H/,"")
    username = status.user.screen_name
    puts "judge呼び出し #{@@data[username]} #{reply}"
    
    #不正な入力
    if @@data[username].is_a?(Hash) == false 
      puts "強制終了"
      return 0
    end
    return 0 if reply.size != @@data[username]["answer"].size 
    
    eat = 0
    bite = 0
    i = 0
    @@data[username]["count"] += 1
    reply.each_char do |c1|
      j = 0
      @@data[username]["answer"].each_char do |c2|
        if c1 == c2
          eat += 1  if i == j
          bite += 1 if i != j
          break
        end
        j+=1
      end
      i+=1
    end
    $client.update("@#{username} #{@@data[username]["count"]}回目:#{eat}EAT-#{bite}BITE",:in_reply_to_status_id => status.id)
    if eat == @@data[username]["answer"].size
      ret = @@data[username]["count"]
      time = Time.now.to_i - @@data[username]["time"]
      puts time
      @@data[username] = Time.now + NUMERON_LIMIT
      score = (70*(2.0/5.0)**(ret/5.0)).to_i
      $client.update("@#{username} #{ret}回で正解しました！(経過時間:#{time}秒) ポイントを #{score}毛 獲得しました！\n次回は#{@@data[username].to_s[11..18]}よりプレイ可能",:in_reply_to_status_id => status.id)
      return score
    end
    return 0
  end
  
  module_function :initialize
  module_function :generate
  module_function :judge
end

Numeron.initialize
