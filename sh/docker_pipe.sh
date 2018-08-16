#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_use()
{
  echo 'USE: docker_pipe.sh [IP_ADDRESS]'
  echo '  IP_ADDRESS defaults to localhost'
  echo
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_use
${MY_DIR}/docker_build.sh
${MY_DIR}/container_down.sh
${MY_DIR}/container_up.sh $*
${MY_DIR}/container_logs.sh
${MY_DIR}/ci_smoke_tests.sh $*
