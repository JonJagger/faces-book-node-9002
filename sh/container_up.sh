#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
source ${MY_DIR}/env-vars.sh

readonly IP=${1:-localhost}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_till_docker_container_is_up()
{
  for i in {1..20}; do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${APP_CONTAINER}$ ; then
      echo "UP on port ${APP_PORT}"
      return
    else
      echo -n '.'
      sleep 0.1
    fi
  done
  echo "NOT up on port ${APP_PORT}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

wait_till_web_server_is_ready()
{
  for i in {1..20}; do
    if curl --fail -X GET "http://${IP}:${APP_PORT}/ready" &> /dev/null; then
      echo "READY on port ${APP_PORT}"
      return
    else
      echo -n '.'
      sleep 0.1
    fi
  done
  echo "NOT ready on port ${APP_PORT}"
  ${MY_DIR}/container_logs.sh
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker run \
  --detach \
  --name ${APP_CONTAINER} \
  --publish ${APP_PORT}:${APP_PORT} \
  --env APP_PORT=${APP_PORT} \
    ${DOCKER_REGISTRY_URL}/${APP_IMAGE}

wait_till_docker_container_is_up
wait_till_web_server_is_ready
