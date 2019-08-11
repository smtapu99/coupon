module ActiveRecordHelper
  # Executes the given block +retries+ times (or forever, if explicitly given nil),
  # catching and retrying SQL Deadlock errors.
  def self.retry_lock_error(retries = 100, &block)
    begin
      yield
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /Deadlock found when trying to get lock/ and (retries.nil? || retries > 0)
        retry_lock_error(retries ? retries - 1 : nil, &block)
      else
        raise e
      end
    end
  end
end
