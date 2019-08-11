require 'net/http'
require 'socket'

def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
ensure
  Socket.do_not_reverse_lookup = orig
end

task "warmup:local" => :environment do |t, args|
  time_start = Time.now
  begin
    uri = URI("http://#{local_ip.to_s}/pcadmin/users/sign_in")
    Net::HTTP.get(uri)
    time_finish = Time.now
    total_time = time_finish - time_start
    if total_time < 60
      medida = "seconds"
    else
      total_time = total_time / 60
      medida = "minutes"
    end
    puts " Warming Up took #{total_time} #{medida}"
  rescue Exception => e
    puts 'error'
  end
end
