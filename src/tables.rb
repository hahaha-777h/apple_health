require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "./db/health_data.db"
)

class HealthDate < ActiveRecord::Base
  self.table_name = "health_dates"
  has_many :health_metrics
end


class HealthMetric < ActiveRecord::Base
  self.table_name = "health_metrics"
  belongs_to :health_date
end
