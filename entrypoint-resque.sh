#!/bin/bash

ruby fix_dns_resolve.rb
bundle exec rake resque:workers QUEUE='*' COUNT='5'