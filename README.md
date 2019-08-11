# Savings United Coupon App Engine [![CircleCI](https://circleci.com/gh/pcvg/app.svg?style=svg&circle-token=e896536c841184795307e1b6b0dbe4f6aefac455)](https://circleci.com/gh/pcvg/app) [![Coverage Status](https://coveralls.io/repos/github/pcvg/app/badge.svg?branch=master&t=lAyrMr)](https://coveralls.io/github/pcvg/app?branch=master)

App Engine is Rails application for White Label Solutions (WLS) and coupon portals such as cupon.es, kupon.pl, etc.

Development setup relies on Docker microservices described in `docker-compose.yml`. Initialisation of development environment (e.g. dependency installation) is managed in `docker-entrypoint.sh`.

## Network topology

Savings United's network is described in [files/network-topology-graph.png](files/network-topology-graph.png).

Graph can be edited with [draw.io](https://www.draw.io) using `files/network-topology.graph.xml` as source from GitHub.

## Requirements

- [Docker CE](https://www.docker.com/community-edition)
- [docker-sync](https://github.com/EugenMayer/docker-sync) (macOS-only)

## Ruby version

Current Ruby version is `2.6.3`.

Ruby version is designated as following:

| Environment   | Points of interest                       |
| ---           | ---                                      |
| `development` | `image` field in `docker-compose.yml`    |
| `test`        | `image` fields in `.circleci/config.yml` |
| `production`  | Ruby version number in `.ruby-version`   |
| `all`         | Ruby version number in `Gemfile`         |


Ruby images for development and test environments (as well as for deployment) are automatically published to [Docker Hub](https://hub.docker.com/r/savingsutd/gcp-ruby/builds/) based on releases of [pcvg/gcp-ruby](https://github.com/pcvg/gcp-ruby). Releases have to be created on GitHub in order to trigger the automation.

## Setup

ATTENTION: use the below guidance for Docker-based local environment. For non-Docker environment, please refer to documentation in [README.rdoc](README.rdoc).

1. Clone Repository

        $ git clone https://user.name@github.com/pcvg/app.git app-engine

2. Move into cloned folder

        $ cd app-engine

3. Start application

    - Linux:

            $ docker-compose up

    - macOS:

            $ docker-sync-stack start

4. When Bundler completes and server (i.e. Puma) initialises, setup database

        $ docker-compose exec web bundle exec rake db:migrate db:seed

5. (On 1st run) restart Resque worker service as it has failed to start without seeded data

        $ docker-compose restart worker

## Useful commands

- Log in to web container

        $ docker-compose exec web bash

- Display log output from all microservices

        $ docker-compose logs -f

- Display log output from single service

        $ docker-compose logs -f redis

- Tail application log

        $ docker-compose exec web tail -100f log/development.log

- Run Rake task

        $ docker-compose exec web bundle exec rake --version

- Dump database

        $ docker-compose exec db bash -lc "mysqldump -u root -p -h localhost pannacotta > /var/lib/mysql/pannacotta.sql"

  NB! Dumps database inside database container.

### macOS

- Remove all containers incl. volumes

        $ docker-sync-stack clean

  NB! Removes all data incl. database, and gem cache!

### Linux

- Start services in the background, e.g. on 2nd run

        $ docker-compose up -d

- Stop all services

        $ docker-compose stop

- Kill all containers

        $ docker-compose down

  NB! Removes all data incl. database, and gem cache!

## Running tests

1. If using Docker, start and log in to Docker as guided in [Setup](#setup) and [Useful commands](#useful-commands)
2. Set up test database

        $ RAILS_ENV=test bundle exec rake db:create db:migrate

3. Run tests with coverage report

        $ RAILS_ENV=test CI=true bundle exec rspec

## Syncing assets

Syncing assets (e.g. images) from production to staging can be performed with `gsutil`, selecting only necessary endpoints of production bucket:

```sh
$ caffeinate gsutil -m rsync -r gs://static.savings-united.com/medium gs://static-staging.savings-united.com/medium
$ caffeinate gsutil -m rsync -r gs://static.savings-united.com/coupon gs://static-staging.savings-united.com/coupon
$ caffeinate gsutil -m rsync -r gs://static.savings-united.com/assets gs://static-staging.savings-united.com/assets
$ caffeinate gsutil -m rsync -r gs://static.savings-united.com/shop gs://static-staging.savings-united.com/shop
$ caffeinate gsutil -m rsync -r gs://static.savings-united.com/images gs://static-staging.savings-united.com/images
$ caffeinate gsutil -m rsync -r gs://static.savings-united.com/setting gs://static-staging.savings-united.com/setting
$ caffeinate gsutil -m rsync -r gs://static.savings-united.com/site gs://static-staging.savings-united.com/site
```

## Rollback

Rollback should be performed to minimise downtime whenever

- application fails consistently ([Application failure](#application-failure))
- deployment fails with some services promoted to production ([Deployment failure](#deployment-failure))

Rollback prerequisities:

1. Ensure `gcloud` utility is available. If not, install [Google Cloud SDK](https://cloud.google.com/sdk/)
2. Authorise `gcloud` to access GCP

        $ gcloud auth login

3. Switch to production project on GCP

        $ gcloud config set project savingsunited-production

### Application failure

On application failure, most common problem is `Application error` that appears consistently on uncached pages, e.g. https://cupon.es/pcadmin

Steps:

1. Identify version of last stable service to roll back to, e.g. `20180528t135219`
2. Start last stable

        $ gcloud app versions start <version>

3. Switch traffic to last stable service and version, as per service, e.g. `default` and `resque-worker`

        $ gcloud app services set-traffic <service> --splits <version>=1

4. Identify version of failed service
5. Stop failed services

        $ gcloud app versions stop <version>

6. Delete failed services

        $ gcloud app versions delete <version>

7. Log in to one stable instance using GCP web interface by clicking _App Engine_ > _Instances_ > _SSH_
8. Run stylesheet preprocessing task to fix potentially broken layouts on all sites

        $ sudo docker exec -it gaeapp bundle exec rake stylesheets:process_all

9. Purge cache for all sites using one of following ways:

  - one by one: Purge section in admin area
  - all at once: Fastly web interface by clicking _White-label Sites_ > _PURGE_ > _Purge all_ > _PURGE_

10. Stand by till services recover. Recovery could take up to 30 min before application becomes entirely available. NewRelic monitoring should show performance upcurve on recovery.

### Deployment failure

1. Identify services and versions that were promoted to production
2. Start last stable service version

        $ gcloud app versions start <version>

3. Switch traffic to last stable service and version, as per service, e.g. `default` and `resque-worker`

        $ gcloud app services set-traffic <service> --splits <version>=1

4. Identify version of failed service
5. Stop failed services

        $ gcloud app versions stop <version>

6. Delete failed services

        $ gcloud app versions delete <version>

## Hotfixes

Hotfixes can be delivered faster if most recent commit includes `[hotfix]` so that tests are being skipped.

## Troubleshooting

### `web` container fails to start

Check if port `80` is not reserved for already running service on host.

### `worker` container fails to start

Check if database has any data.

### If database already exists while set up database for running tests

Try to add `env` to the command-line

    $ env RAILS_ENV=test bundle exec rake db:create db:migrate

### Running commands on live GAE instances

1. Set GAE project, e.g. for staging environment:

        gcloud config set project savingsunited-staging

2. Connect to instance over SSH by using web or `gcloud` command line interface, e.g.:

        gcloud app instances ssh --service default --version <version> <instance name>

  `<version>` and `<instance name>` can be acquired with

        gcloud app instances list

3. Run command against `gaeapp` default Docker service, e.g. for Rake version:

        docker exec -it gaeapp bundle exec rake -V

