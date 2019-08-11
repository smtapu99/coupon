class CouponCodeImport
  require 'rubygems'
  require 'roo'

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :site_id

  validates_presence_of :file, :site_id

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def run
    return false unless self.valid?

    data = collect_data
    begin
      ActiveRecord::Base.transaction do
        import_result = CouponCode.import @columns, data, validate: true, on_duplicate_key_update: @columns
        if import_result.failed_instances.count <=0
          true
        else
          import_result.failed_instances.each_with_index do |coupon_code, index|
            coupon_code.errors.full_messages.each do |message|
              errors.add :base, "Coupon code for coupon_id '#{coupon_code.coupon_id}' and code '#{coupon_code.code}' #{message}"
            end
          end
          raise ActiveRecord::Rollback
          false
        end
      end
    rescue Exception => e
      errors.add :base, e.message
      false
    end

  end

  private

    def collect_data
      site_id    = load_site_id
      data       = []

      spreadsheet = open_spreadsheet
      header      = spreadsheet.row(1)

      allowed_columns = header.select { |col| CouponCode::allowed_import_params.include?(col.to_sym) }
      @columns        = allowed_columns.push(:site_id, :is_imported).map { |idx| idx.to_sym == :coupon_code_id ? :id : idx }

      (2..spreadsheet.last_row).map do |i|
        data_as_hash = Hash[[header, spreadsheet.row(i)].transpose]
        allowed_data = data_as_hash.to_hash.slice(*CouponCode::allowed_import_params.map(&:to_s))
        code_new_hash = {}

        coupon_code_id = allowed_data['coupon_code_id']
        if coupon_code_id.present?
          coupon_code = CouponCode.find(coupon_code_id.to_i)
        else
          coupon_code = CouponCode.new
        end

        allowed_data.each_pair do |key, value|
          case key
          when 'coupon_code_id'
           key = 'id'
           value
          when 'coupon_id'
            key = 'coupon_id'

            if value.present?
              value = value
            else
              value = coupon_code.coupon_id
            end
          when 'code'
            key = 'code'

            if value.present?
              if "#{value}".index('e+')
                float_number = "%f" % value
                value = value.to_i
              else
                value = value
              end
            else
              value = coupon_code.code
            end
          when 'end_date'
            key = 'end_date'

            if value.present?
              value = DateTime.parse("#{value} 00:00:00").to_s(:db)
            else
              value = coupon_code.end_date
            end
          end

          code_new_hash.merge!({key => value})
        end

        values = code_new_hash.merge!(site_id: site_id, is_imported: 1).values
        data += [values]
      end

      data
    end

    def load_site_id
      return @site_id.to_i if @site_id.present?

      if Site.current.present?
        Site.current.id
      else
        nil
      end
    end

    def open_spreadsheet
      case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path, csv_options: {col_sep: ";"})
      when '.xls' then Roo::Spreadsheet.open(file.path, extension: :xls)
      when '.xlsx' then Roo::Spreadsheet.open(file.path, extension: :xlsx)
      else raise "Unknown file type: #{file.original_filename}"
      end
    end
end
