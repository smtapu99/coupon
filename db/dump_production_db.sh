#!/bin/bash

cat <<EOF
Usage: $0 [options]

-p          Password
-h          Host
-u          User
-d          Database
-o          Only Content Flag [boolean, optional]
EOF

while getopts u:p:h:d:o: option
do
  case "${option}"
  in
  p) PASSWORD=${OPTARG};;
  h) HOST=${OPTARG};;
  u) USER=${OPTARG};;
  d) DATABASE=$OPTARG;;
  o) ONLY_CONTENT=$OPTARG;;
  esac
done

DB_FILE=suapp_production_dump.sql
EXCLUDED_TABLES=(
tracking_users
tracking_clicks
sessions
)

IGNORED_TABLES_STRING=''
for TABLE in "${EXCLUDED_TABLES[@]}"
do :
   IGNORED_TABLES_STRING+=" --ignore-table=${DATABASE}.${TABLE}"
done

if ! [ "$ONLY_CONTENT" = true ]; then
echo "Dump structure"
mysqldump --host=${HOST} --user=${USER} --password=${PASSWORD} --set-gtid-purged=OFF --single-transaction --no-data ${DATABASE} > ${DB_FILE}
fi

echo "Dump content"
mysqldump --host=${HOST} --user=${USER} --password=${PASSWORD} ${DATABASE} --set-gtid-purged=OFF --no-create-info ${IGNORED_TABLES_STRING} >> ${DB_FILE}
