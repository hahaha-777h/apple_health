#csvファイルを読み込んで、データベースを更新する。
def update_data_from_csv(daily_data)
  daily_data.each do |date, metrics|
    date_obj = HealthDate.find_or_create_by(record_date: date)
    date_obj.health_metrics.destroy_all
    date_obj.health_metrics.create(
      # :step_count => metrics[:step_count]と同じ
      step_count: metrics[:step_count],
      burned_energy: metrics[:burned_energy],
      flights_climbed: metrics[:flights_climbed],
      headphone_volume: metrics[:headphone_volume],
      walking_speed: metrics[:walking_speed],
      step_length: metrics[:step_length]
    )
  end
end
