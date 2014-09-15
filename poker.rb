class Trump
  def initialize(suite,num)
    @suite = suite
    @num = num
  end
  
  def output
    case @num
    when 14
      num = "A"
    when 11
      num = "J"
    when 12
      num = "Q"
    when 13
      num = "K"
    else
      num = @num
    end
    return "#{@suite}#{num}"
  end
  
  attr_reader :suite
  attr_reader :num
end

module Poker
  def initial
    @@data = Hash.new
    @@data.default = 0
    @@card = Array.new
    for i in ["♡","♢","♤","♧"]
      for j in 2..14  #Aは14として扱う
        @@card << Trump.new(i,j)
      end
    end
  end
  
  def deal(status)
    puts "yobidasi"
    username = status.user.screen_name
    talon  = @@card.shuffle
    hand = Array.new
    puts talon
    5.times do
      hand << talon.pop
    end
    card = ""
    puts hand
    hand.each do |i|
      card+=i.output+" "
    end
    puts card
    @@data[username] = Hash.new
    @@data[username]["hand"] = hand
    @@data[username]["talon"]= talon
    @@data[username]["bet"]  = status.text.gsub(/\D/,"")  #賭けポイント
    #judge(hand)
    $client.update("@#{username} #{card}",:in_reply_to_status_id => status.id)
    return @@data[username]["bet"]
  end
 
  def change(status)
    username = status.user.screen_name
    order = status.text.gsub(/[^0-1]/,"")
    puts "order:#{order}"
    i=0
    order.each_char do |c|
      if c == "1"
        @@data[username]["hand"][i] = @@data[username]["talon"].pop
      end
      i+=1
    end
    @@data[username]["result"]=""
    @@data[username]["hand"].each do |i|
      @@data[username]["result"]+=i.output+" "
    end
  end
  
  def judge(status)
    username = status.user.screen_name
    hand = @@data[username]["hand"]
    suitetime = Hash.new
    suitetime.default = 0
    numtime = Hash.new
    numtime.default = 0
    hand.each do |i|    #それぞれの数字、マークの出現回数をハッシュに代入
      suitetime[i.suite]+=1
      numtime[i.num]+=1
    end
    
    #ストレート？
    if numtime.size == 5 #数字が5種類
      numlist = Array.new
      hand.each do |i|
        numlist << i.num
      end
      if numlist.max - numlist.min == 4
        if numlist.max == 14
          straight = 2 #ロイヤルフラグ
        else
          straight = 1
        end
      end
    end
    
    #フラッシュ？
    flash = 1 if suitetime.size == 1 #マークが一種類
    
    #ペア系判定
    min = numtime.min { |a,b| a[1] <=> b[1] }[1] #同じ数字が出た回数の最大最小
    max = numtime.max { |a,b| a[1] <=> b[1] }[1]
    puts "#{min},#{max}"
    if max == 4
      pair = 5  #フォーカード
    elsif min == 2 and max == 3
      pair = 4  #フルハウス
    elsif max == 3
      pair = 3  #スリーカード
    elsif max == 2
      i = 0
      numtime.each do |key,value|
        i += 1 if value == 2
      end
      pair = 2 if i == 2  #ツーペア
      pair = 1 if i == 1  #ワンペア
    end
    
    #結果
    if straight == 1 and flash == 1
      win = "ストレートフラッシュ"
    elsif straight == 1
      win = "ストレート"
    elsif flash == 1
      win = "フラッシュ"
    elsif pair == 5
      win = "フォーカード"
    elsif pair == 4
      win = "フルハウス"
    elsif pair == 3
      win = "スリーカード"
    elsif pair == 2
      win = "ツーペア"
    elsif pair == 1
      win = "ワンペア"
    else
      win = "ブタ"
    end
    $client.update("@#{username} #{@@data[username]["result"]}\n結果：#{win}",:in_reply_to_status_id => status.id)
  end
  
  module_function :initial
  module_function :change
  module_function :deal
  module_function :judge
end

Poker.initial
#Poker.deal("Feru")
#order=STDIN.gets
#Poker.change("Feru",order)
