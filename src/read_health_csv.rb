#一行目をlabelにして、dateをkeyとしたら二次元配列を作る。
def read_health_csv(csv_file_path)
  daily_data = {}
  label = []
  begin
    File.open(csv_file_path) do |fd|
      fd.each_line do |line|
        fields = line.chomp.split(",")
        if(label.empty?)
          label = fields
          label.shift
          label.map! {|col| col.to_sym}
          next
        end
        daily_data[fields.shift] = label.zip(fields.map{ |s| s.to_i}).to_h
      end
    end
  rescue =>e
    STDERR.puts(e.message)
    exit 1
  end
  return (daily_data)
end

# data = read_health_csv("./health_summary.csv")

# pp data