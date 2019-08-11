class CsvExportWorker < BaseWorker
  @queue = :csv_export_queue

  def self.perform csv_export_id
    retries = 2
    begin
      csv_export = CsvExport.find(csv_export_id)
    rescue Exception => e
      sleep 2
      if (retries -= 1) == 0
        retry
      else
        raise 'CSV Export ' + csv_export_id.to_s + ' not found'
      end
    end

    begin
      csv_export.update_attribute(:status, 'running')
      csv_export.update_attribute(:last_executed, Time.zone.now)

      records = csv_export.run_export

      path = "/tmp/#{filename(csv_export)}"

      relation_xlsx = records.to_export_xls
      # relation_xlsx.serialize(filename(csv_export));
      serialized_relation = relation_xlsx.to_stream;

      File.open(path, 'w') do |f|
        f.write(serialized_relation.read)
      end

      csv_export.file = File.open(path)

      if csv_export.save
        csv_export.update_attribute(:error_messages, nil)
        csv_export.update_attribute(:status, 'done')
      else
        csv_export.update_attribute(:error_messages, csv_export.errors.full_messages)
        csv_export.update_attribute(:status, 'error')
      end
    rescue Exception => e
      csv_export.update_attribute(:error_messages, e.to_s)
      csv_export.update_attribute(:status, 'error')
    end
  end

  def self.filename csv_export
    "#{csv_export.id.to_s}_#{csv_export.export_type.singularize.downcase}_#{Time.zone.now.to_date}.xlsx"
  end
end
