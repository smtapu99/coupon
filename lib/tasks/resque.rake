require "resque/tasks"

# run with
# rake resque:work QUEUE=* BACKGROUND=yes
# kill with
# sudo kill -9  `ps aux | grep [r]esque | grep -v grep | cut -c 10-16`

namespace :resque do
  task :setup => :environment

  desc "Quit running workers nicely after finishing their job"
  task :kill_all => :environment do
    Resque.workers.each {|w| w.unregister_worker}

    # pids = Array.new
    # Resque.workers.each do |worker|
    #   pids.concat(worker.worker_pids)
    # end
    # if pids.empty?
    #   # puts "No workers to kill"
    # else
    #   syscmd = "kill -s QUIT #{pids.join(' ')}"
    #   # puts "Running syscmd: #{syscmd}"
    #   exec(syscmd)
    # end
    # exit
  end

end
