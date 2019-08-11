#!/usr/bin/env bash
apt-get update
apt-get -y install libmysqlclient-dev ruby-dev
sudo su - vagrant -c 'git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build'
sudo su - vagrant -c '/home/vagrant/.rbenv/bin/rbenv install 1.9.3-p448'
sudo su - vagrant -c '/home/vagrant/.rbenv/bin/rbenv global 1.9.3-p448'
sudo su - vagrant -c 'gem install rdoc'
sudo su - vagrant -c 'gem install bundle'
sudo su - vagrant -c 'bundle install --gemfile=/vagrant/Gemfile'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-<version> mysql-server/root_password_again password root'
apt-get -y install mysql-server
mysql -u root -proot -e "CREATE DATABASE pannacotta CHARACTER SET utf8 COLLATE utf8_bin;"
sudo su - vagrant -c 'cd /vagrant/; bin/rake db:migrate RAILS_ENV=development'
