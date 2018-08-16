#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
source ${MY_DIR}/env-vars.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_till_up() # $1==container_name
{
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${1}$ ; then
      echo "Up on port ${APP_PORT}"
      return
    else
      sleep 0.2
    fi
  done
  echo "${1} not up after 2 seconds"
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker run \
  --detach \
  --name ${APP_CONTAINER} \
  --publish ${APP_PORT}:${APP_PORT} \
  --env APP_PORT=${APP_PORT} \
    ${DOCKER_REGISTRY_URL}/${APP_IMAGE}

# This is the container up...
wait_till_up ${APP_CONTAINER}

# But it might not be ready yet.
# Crude readyness test is good enough for now...
sleep 2


# replace this sleep with a structure similar to wait_till_up() above
# but instead of looping around the [docker ps]
# loop around a /ready curl











