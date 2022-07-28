require 'CSV'
require 'date'

class Etl

  REQUIRED_HEADERS = [:first_name, :last_name, :dob, :member_id, :effective_date]

  def self.run
    csv = import_csv
    error_rows = process_output(csv)
    generate_report(error_rows)
    puts error_rows.inspect
  end

  def self.generate_report(errors)
    output_csv =  CSV.parse(File.read('output.csv'), headers: true, header_converters: :symbol)
    out_file = File.new('report.txt', 'w')
    out_file.puts 'Report Summary', ''
    out_file.puts "Processed #{output_csv.size} row successfully"
    out_file.puts "Error Count: #{errors.size}", ''
    errors.each {|line| out_file.puts line.inspect }
    out_file.close
  end

  def self.process_output(imported_csv)
    error_rows = []
    CSV.open("output.csv", "w") do |output_csv|
      output_csv << imported_csv.headers
      imported_csv.each do |row|
        row = transform_row(row)
        if failed_check(row)
          error_rows << row
          next
        end
        output_csv << row
      end
    end
    return error_rows
  end

  def self.failed_check(row)
    return true if check_if_missing_required(row)
    false
  end

  def self.transform_row(row)
    transform_all_date_fields(row)
    row
  end

  def self.check_if_missing_required(row)
    REQUIRED_HEADERS.each do |header|
      return true if row.fetch(header) == nil
    end
    false
  end

  def self.transform_all_date_fields(row)
    row[:dob] = transform_date(row[:dob])  if row[:dob] != nil
    row[:effective_date] = transform_date(row[:effective_date])  if row[:effective_date] != nil
    row[:expiry_date] = transform_date(row[:expiry_date])  if row[:expiry_date] != nil
  end

  def self.transform_date(date)
    return date.iso8601 if date.is_a?(DateTime)
    Date.parse(date).iso8601
  rescue Date::Error
    begin
      Date.strptime(date, '%m/%d/%y').iso8601
    rescue Date::Error
      Date.strptime(date, '%m-%d-%y').iso8601
    end
  end

  def self.import_csv
    # needed to remove leading/trailing whitespace
    strip_converter = proc {|field| field.strip }
    CSV::Converters[:strip] = strip_converter
    parsed_csv = CSV.parse(File.read("input.csv"), headers: true, header_converters: :symbol, converters:  [:all, :strip])
  end
end

Etl.run
