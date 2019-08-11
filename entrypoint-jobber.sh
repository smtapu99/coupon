#!/bin/bash

if ruby fix_dns_resolve.rb ; then
    echo "DNS resolution test passed"
else
    echo "This host is unable to resolve DNS addresses"
    exit 1
fi

set -o errexit

configfile="/root/.jobber"

function pipeEnvironmentVariables() {
  local environmentfile="/etc/profile.d/jobber.sh"
  cat > ${environmentfile} <<_EOF_
  #!/bin/sh
_EOF_
  sh -c export >> ${environmentfile}
}

if [ ! -f "${configfile}" ]; then
  touch ${configfile}
  cat > ${configfile} <<_EOF_
---
_EOF_
  for (( i = 1; ; i++ ))
  do
    VAR_JOB_ON_ERROR="JOB_ON_ERROR$i"
    VAR_JOB_NAME="JOB_NAME$i"
    VAR_JOB_COMMAND="JOB_COMMAND$i"
    VAR_JOB_TIME="JOB_TIME$i"

    if [ ! -n "${!VAR_JOB_NAME}" ]; then
      break
    fi

    it_job_on_error="Continue"
    if [ -n "${!VAR_JOB_ON_ERROR}" ]; then
      it_job_on_error=${!VAR_JOB_ON_ERROR}
    fi
    it_job_name=${!VAR_JOB_NAME}
    it_job_time=${!VAR_JOB_TIME}
    it_job_command=${!VAR_JOB_COMMAND}

    cat >> ${configfile} <<_EOF_
- name: ${it_job_name}
  cmd: ${it_job_command}
  time: '${it_job_time}'
  onError: ${it_job_on_error}
  notifyOnError: false
  notifyOnFailure: false
_EOF_
  done
fi

cat ${configfile}

if [ "$1" = 'jobberd' ]; then
  pipeEnvironmentVariables
  exec jobberd
fi

exec "$@"