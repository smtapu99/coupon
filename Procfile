web: bundle exec puma -C config/puma.rb
worker:bundle exec rake resque:work QUEUE='*' COUNT=2
health_check: bundle exec rackup -p 8080 health_check.ru