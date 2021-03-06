require 'twitter'
require 'tweetstream'
require 'pp'
require 'uri'
require_relative 'key'
require_relative 'numeron'
require_relative 'poker'
require_relative 'feru'

NUMERON_LIMIT = 1800
POKER_LIMIT = 600

streamclient = TweetStream::Client.new

file = open("count.dat","r+")
ke = Hash.new
ke.default = 0
eq = Hash.new
eq.default = [0,0]

while line = file.gets
  linearray = line.split(" ")
  ke[linearray[0]] = linearray[1].to_i
  p line
end
file.close

i=0
ke.each do |name,count|
  a="#{name} #{count}"
  a+=" "*(30-a.size)
  print a
  i+=1
  puts "" if i%3==0
end
puts ""

$client.update("稼働を開始しました#{Time.now}")

begin
  streamclient.userstream do |status|
    #TL取得
    username = status.user.screen_name
    contents = status.text
    id = status.id
    str = username + ":" + contents
    puts str
    
    if contents =~ /毛ポイント/ && username != "_ke_bot_"
      $client.update("@#{username}さんの毛ポイントは #{ke[username]}毛 です。",:in_reply_to_status_id => id)
      
    elsif contents =~ /毛ランキング|毛ランク/ && username != "_ke_bot_"
      rank = ke.sort{|(k1, v1), (k2,v2)| v2 <=> v1}
      puts rank
      i = 0
      j = 0
      prev = 0
      rank.each{|key, value|
        i += 1
        if value != prev
          j = i
          prev = value
        end
      break if key == username
      }
      puts i
      $client.update("@#{username}さんは毛ランク#{j}位です。(#{ke.size}人中)",:in_reply_to_status_id => id)
       
    elsif contents =~ /毛/ && id != "_ke_bot_"
      begin
        ke[username]+=1
        $client.update("@#{username} 毛",:in_reply_to_status_id => id) unless username == "_ke_bot_"
      rescue
        puts "muri"
        $client.update("@#{username} #{er.message}")
      else
        puts "success"
      end
      file = open("count.dat","w")
      ke.each do |name,count|
        file.puts("#{name} #{count}")
      end
      file.close
    end
   
    if contents == "起きた" or contents == "むくり" or contents == "朝" or contents == "おはよう"
      $client.update("@#{username} おはようの毛",:in_reply_to_status_id => id)
    end
   
    if contents == "きたく" or contents == "ただいま"
      $client.update("@#{username} おかえりの毛",:in_reply_to_status_id => id)
    end
   
    if contents =~ /sonohennniiruガチャ/
      puts "sonohenn"
      $client.update_with_media("@#{username} ",File.open("naja.png"),:in_reply_to_status_id => id)
    end
   
    if contents =~ /sonohennniiru10連ガチャ/
      10.times do
        $client.update_with_media("@#{username} ",File.open("naja.png"),:in_reply_to_status_id => id)
      end
    end
   
    if contents =~ /うしうしガチャ/
      fname = "usiusi" + rand(1..10).to_s + ".jpg"
      puts fname
      $client.update_with_media("@#{username} ",File.open(fname),:in_reply_to_status_id => id)
    end
    
    if contents =~ /Feruガチャ/
      if ke[username]<5
        $client.update("@#{username} 毛ポイントが足りません",:in_reply_to_status_id => id)
      else
        feru(status)
        ke[username] -= 5
      end
    end
=begin   
    #ヌメロン判定
    if contents =~ /@_ke_bot_.*\d{4}|@_ke_bot_.*\h{6}/
      ke[username] += Numeron.judge(status)
    end
   
    #ヌメロン開始
    if contents =~ /ヌメロン.*16/
      Numeron.generate(status,6)
    elsif contents =~ /@_ke_bot_.*あそぼ|ヌメロン/
      Numeron.generate(status,4)
    end
=end 
    #ポーカー
    if contents =~ /ポーカー.*\d+/
      puts "ポーカー開始"
      ke[username]-=Poker.deal(status,ke[username])
    elsif contents =~ /@_ke_bot_.*[0-1]{5}/
      Poker.change(status)
      ke[username]+=Poker.judge(status)
    end
  end
  rescue Interrupt, StandardError
  $client.update ("稼働を停止しました#{Time.now}")
end
