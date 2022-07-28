require 'CSV'
require 'date'

class Etl

  REQUIRED_HEADERS = [:first_name, :last_name, :dob, :member_id, :effective_date]

  def self.run
    csv = import_csv
    error_rows = process_output(csv)
    puts error_rows.inspect
  end

  def self.process_output(imported_csv)
    error_rows = []
    CSV.open("output.csv", "w") do |output_csv|
      output_csv << imported_csv.headers
      imported_csv.each do |original_row|
        transform_all_date_fields(original_row)
        if check_if_missing_required(original_row)
          error_rows << original_row
          next
        end
        output_csv << original_row
      end
    end
    return error_rows
  end

  def self.check_if_missing_required(row)
    return true if row.fetch(:first_name) == nil
    return true if row.fetch(:last_name) == nil
    return true if row.fetch(:dob) == nil
    return true if row.fetch(:member_id) == nil
    return true if row.fetch(:effective_date) == nil
  end

  def self.transform_all_date_fields(row)
    row[:dob] = transform_date(row[:dob])  if row[:dob] != nil
    row[:effective_date] = transform_date(row[:effective_date])  if row[:effective_date] != nil
    row[:expiry_date] = transform_date(row[:expiry_date])  if row[:expiry_date] != nil
  end

  def self.transform_date(date)
    return date.iso8601 if date.is_a?(DateTime)
    # Date.parse(date).iso8601
  end

  def self.import_csv
    # needed to remove leading/trailing whitespace
    strip_converter = proc {|field| field.strip }
    CSV::Converters[:strip] = strip_converter
    parsed_csv = CSV.parse(File.read("input.csv"), headers: true, header_converters: :symbol, converters:  [:all, :strip])
  end
end
