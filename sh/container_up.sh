#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
source ${MY_DIR}/env-vars.sh

readonly IP=${1:-localhost}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_till_container_is_up()
{
  local name=${APP_CONTAINER}
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${name}$ ; then
      echo "UP on port ${APP_PORT}"
      return
    else
      sleep 0.2
    fi
  done
  echo "NOT up on port ${APP_PORT} after 2 seconds"
  docker logs "${name}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_till_web_server_is_ready()
{
  local name=${APP_CONTAINER}
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if curl --fail -X GET "http://${IP}:${APP_PORT}/ready" &> /dev/null; then
      echo "READY on port ${APP_PORT}"
      return
    else
      sleep 0.2
    fi
  done
  echo "NOT ready on ${APP_PORT} after 2 seconds"
  docker logs "${name}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker run \
  --detach \
  --name ${APP_CONTAINER} \
  --publish ${APP_PORT}:${APP_PORT} \
  --env APP_PORT=${APP_PORT} \
    ${DOCKER_REGISTRY_URL}/${APP_IMAGE}

wait_till_container_is_up
wait_till_web_server_is_ready
