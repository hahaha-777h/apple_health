require "./src/tables.rb"
require "./src/xml_parser_to_csv.rb"
require "./src/read_health_csv.rb"
require "./src/update_from_csv.rb"
require "./src/show_data.rb"


convert_health_xml_to_csv("./xml/export.xml", "health_summary.csv")

daily_data = read_health_csv("./health_summary.csv")

update_data_from_csv(daily_data)

show_data