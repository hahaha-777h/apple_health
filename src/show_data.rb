def show_data(limit = nil)
  dates = HealthDate.order(:record_date).includes(:health_metrics)
  if(dates.empty?)
    puts("Data not found.")
    return
  end

  # puts("date ")

  dates.each do |date|
    date.health_metrics.each do |metrics|
      puts("date: #{date.record_date} 
            step_count: #{metrics.step_count} 
            burned_energy: #{metrics.burned_energy} 
            flights_climbed: #{metrics.flights_climbed} 
            headphone_volume: #{metrics.headphone_volume} 
            walking_speed: #{metrics.walking_speed} 
            step_length: #{metrics.step_length}")
    end
  end
end
