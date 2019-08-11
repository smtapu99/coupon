#!/bin/bash

set -e

if [ "$1" = 'bundle' ]; then

  if hash bundle 2> /dev/null; then
    echo "Bundler installed"
  else
    gem install bundler
  fi

  bundle install

  yarn install

  echo
  echo 'App Engine init process complete; ready for start up.'
  echo
fi

exec "$@"
