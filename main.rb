require 'net/http'
require 'json'
require 'uri'

# ----- Setting ----- #
scale_dict = {
  10 => '1',
  20 => '2',
  30 => '3',
  40 => '4',
  45 => '5弱', 
  50 => '5強',
  55 => '6弱', 
  60 => '6強',
  70 => '7'
}

depth_dict = {
  10 => '10km',
  20 => '20km',
  30 => '30km',
  40 => '40km',
  50 => '50km',
  60 => '60km',
  70 => '70km',
  80 => '80km',
  90 => '90km',
  100 => '100km'
}

# -------------------- #

def get_eew_data(code, scale_dict, depth_dict)
  uri = URI.parse("https://api.p2pquake.net/v2/history?codes=#{code}&limit=1")
  res = Net::HTTP.get_response(uri)

  if res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body)
    
    if data.is_a?(Array) && !data.empty?
      eew_data = data[0]
      
      eq_id = eew_data['id']
      hypo_name = eew_data.dig('earthquake', 'hypocenter', 'name') || '不明'
      magnitude = eew_data.dig('earthquake', 'hypocenter', 'magnitude') || '不明'
      depth     = eew_data.dig('earthquake', 'hypocenter', 'depth') || '不明'
      eq_time   = eew_data.dig('earthquake', 'time') || '不明'
      max_scale = scale_dict[eew_data.dig('earthquake', 'maxScale')] || '不明'
      
      depth_info = depth_dict[depth] || '不明'
      message   = "< 地震情報 >\n\n>> 震源地\n-#{hypo_name}\n\n"
      message  += ">> マグニチュード\n-M#{magnitude}\n\n"
      message  += ">> 最大震度\n-#{max_scale}\n\n"
      message  += ">> 深さ\n-#{depth_info}\n\n"
      message  += ">> 発生時刻\n-#{eq_time}"
      
      return message
    else
      return "データが見つかりませんでした。"
    end
  else
    return "APIリクエストに失敗しました。HTTPステータスコード: #{res.code}"
  end
end

puts get_eew_data(551, scale_dict, depth_dict)