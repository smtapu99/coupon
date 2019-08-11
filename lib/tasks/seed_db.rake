namespace :seed_db do

  desc "Creates a sample admin user."

  task :user, [:host, :database, :username, :password] => :environment do |t, args|

    @database =  args.to_hash.slice(:host, :database, :username, :password)

    @client = Mysql2::Client.new(
      :host     => @database[:host],
      :database => @database[:database],
      :username => @database[:username],
      :password => @database[:password],
      :encoding => 'utf8'
    )

    @client.query("INSERT INTO `users` (`id`, `email`, `encrypted_password`, `reset_password_token`, `reset_password_sent_at`, `remember_created_at`, `sign_in_count`, `current_sign_in_at`, `last_sign_in_at`, `current_sign_in_ip`, `last_sign_in_ip`, `failed_attempts`, `unlock_token`, `locked_at`, `created_at`, `updated_at`, `role`, `first_name`, `last_name`) VALUES
(1, 'admin@user.com', '$2a$10$Zl4WF2K9b7J5psfbbQbrsuY4Cdt19tMPceyg6yhb0.QfAnLdFBa6.', NULL, NULL, NULL, 0, '2014-03-03 16:43:51', '2014-03-03 16:43:51', '127.0.0.1', '127.0.0.1', 0, NULL, NULL, '2014-03-03 16:43:51', '2014-03-03 16:43:51', 'admin', 'Admin', 'User')");
  end
end
