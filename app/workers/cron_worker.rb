class CronWorker < BaseWorker
  @queue = :cron_queue

  def self.perform task
    Rake::Task[task].invoke
  end
end
