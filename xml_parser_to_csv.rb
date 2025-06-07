require 'nokogiri'
require 'date'

# SAXパーサーの動作を定義するハンドラークラス
class HealthDataHandler < Nokogiri::XML::SAX::Document
  # 処理したいデータタイプと、最終的なカラム名の対応表
  TYPE_MAPPING = {
    'HKQuantityTypeIdentifierStepCount' => :step_count,
    'HKQuantityTypeIdentifierActiveEnergyBurned' => :active_calories,
    'HKQuantityTypeIdentifierFlightsClimbed' => :flights_climbed,
    'HKQuantityTypeIdentifierHeadphoneAudioExposure' => :headphone_volume,
    'HKQuantityTypeIdentifierWalkingSpeed' => :walking_speed,
    'HKQuantityTypeIdentifierWalkingStepLength' => :step_length
  }.freeze

  # 集計結果を格納するハッシュ
  # 構造: { "日付" => { step_count: 1000, distance_km: 0.8 } }
  attr_reader :data

  def initialize
    @data = {}
  end

  # XMLの開始タグが見つかるたびに呼ばれるメソッド
  def start_element(name, attrs = [])

    return unless name == 'Record'

    attributes = attrs.to_h
    type = attributes['type']
    creation_date_str = attributes['creationDate']
    value = attributes['value']

    # 必要な属性が揃っていて、かつ処理対象のタイプでなければ何もしない
    return if type.nil? || creation_date_str.nil? || value.nil?
    return unless TYPE_MAPPING.key?(type)

    # 日付部分だけを取得 (例: "2019-03-11 18:31:04 +0900" -> "2019-03-11")
    date_key = Date.parse(creation_date_str).strftime('%Y-%m-%d')
    
    # 対応表から分かりやすいカラム名を取得
    column_name = TYPE_MAPPING[type]

    # その日付のデータがなければ初期化
    @data[date_key] ||= {}
    # その日付のその項目がなければ0で初期化
    @data[date_key][column_name] ||= 0

    # valueを加算していく
    # 距離などは小数になる可能性があるので to_f を使うのが安全
    @data[date_key][column_name] += value.to_f
  end
end

# --- メインの処理 ---

# 1. ハンドラーを準備
handler = HealthDataHandler.new

# 2. SAXパーサーを作成
parser = Nokogiri::XML::SAX::Parser.new(handler)

# 3. XMLファイルを指定して解析を実行
# ファイル名はご自身のものに変更してください
file_path = 'export.xml'
puts "Parsing #{file_path}..."
parser.parse_file(file_path)
puts "Parsing complete!"

puts "\n--- Aggregated Data ---"
# 日付順に並び替えて表示
sorted_data = handler.data.sort.to_h

require 'csv'

# CSVファイルに出力
CSV.open('health_summary.csv', 'w') do |csv|
  # ヘッダー行を書き込む
  csv << ['date', 'step_count', 'burned_energy', 
              'flights_climbed', 'headphone_volume',
              'walking_speed', 'step_length']
  
  # 各日付のデータを書き込む
  sorted_data.each do |date, metrics|
    csv << [date, metrics[:step_count].to_i, metrics[:active_calories].to_i,
              metrics[:flights_climbed].to_i, metrics[:headphone_volume].to_i,
              metrics[:walking_speed].to_i, metrics[:step_length].to_i]
  end
end

puts "\nSuccessfully saved to health_summary.csv"