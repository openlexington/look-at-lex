require 'json'

path = File.join(File.dirname(__FILE__), 'public',
                 '2014-lexington-ky-budget.json')
json = File.read(path)
data = JSON.parse(json)
numeric_fields = %w(fy_2014_requested fy_2014_mayor_proposed fy_2014_adopted
                    fy_2014_requested_new fy_2014_mayor_proposed_new
                    fy_2014_adopted_new)

data.each_with_index do |row, i|
  row_num = i + 1
  puts "Row ##{row_num}"
  numeric_fields.each do |field|
    value = row[field].to_s
    print "#{field}: #{value}"
    value = value.gsub(/,/, '') # strip commas
    if value.include?('(') && value.include?(')') # negative value
      value = '-' + value.gsub(/\(/, '').gsub(/\)/, '')
    end
    value = value.to_i
    puts " => #{value}"
    row[field] = value
  end
end

File.open(path, 'w') {|f| f.write(JSON.pretty_generate(data)) }
