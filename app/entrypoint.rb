#!/bin/bash

bundle exec puma -C config/puma.rb &

sleep 10

curl -s -H 'Host: cupon.es' http://localhost:1080 > /dev/null &
curl -s -H 'Host: cupom.com' http://localhost:1080 > /dev/null &
curl -s -H 'Host: cupon.com.co' http://localhost:1080 > /dev/null &
curl -s -H 'Host: cupon.cl' http://localhost:1080 > /dev/null &
curl -s -H 'Host: kupon.pl' http://localhost:1080 > /dev/null &
curl -s -H 'Host: sconti.com' http://localhost:1080 > /dev/null &
curl -s -H 'Host: tuscupones.com.mx' http://localhost:1080 > /dev/null

fg %1