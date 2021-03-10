# raw conversion of XSLX to YAML for physical object updates
# requires ruby 2.5+ for Hash#transform_keys
require 'roo'
require 'csv'
require 'yaml'

def transform_key(key)
  result = key.downcase.gsub(' ', '_')
  result =
    case result
    when 'group_key'
     'group_key_id'
    else
     result
    end
  result
end

def transform_key_value(key, value)
  case key
  when 'group_key_id'
    value.to_s.sub('GR', '').to_i
  when 'other_copies'
    { 0 => false, 1 => true }[value.to_i]
  else
    value
  end
end

ARGV.each do |file|
  parsed_csv = Roo::Excelx.new(file, file_warning: :ignore)
  parsed_yml = []
  parsed_csv.each_with_index do |r, i|
    parsed_yml << (parsed_csv.row(1).zip(r)).to_h unless i.zero?
  end
  parsed_yml.map! { |h| h.transform_keys { |k| transform_key(k) } }
  parsed_yml.map! { |h| h.map { |k,v| h[k] = transform_key_value(k,v) }; h }
  File.write(file.gsub('xlsx', 'yml'), parsed_yml.to_yaml)
end
