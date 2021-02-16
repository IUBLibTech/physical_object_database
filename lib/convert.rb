# raw conversion of XSLX to YAML for physical object updates
require 'roo'
require 'csv'
require 'yaml'

ARGV.each do |file|
  parsed_csv = Roo::Excelx.new(file, file_warning: :ignore)
  parsed_yml = []
  parsed_csv.each_with_index do |r, i|
    parsed_yml << (parsed_csv.row(1).zip(r)).to_h unless i.zero?
  end
  File.write(file.gsub('xlsx', 'yml'), parsed_yml.to_yaml)
end

