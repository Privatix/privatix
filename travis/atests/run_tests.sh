#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
  echo Start running tests...
  ssh stagevm@89.38.99.188 <<EOF || exit 1
  #tests_dir=/home/stagevm/tests
  /bin/rm -rf /home/stagevm/tests/
  mkdir /home/stagevm/tests
  cd /home/stagevm/tests/
  git clone git@github.com:Privatix/privatix.git
  cd /home/stagevm/tests/privatix/
  git checkout feature/ks-BV-1675
  source /home/stagevm/tests/privatix/tests/integrational/helpers/setenv.sh || exit 1
  cd /home/stagevm/tests/privatix/tests/integrational || exit 1
  npm install || exit 1
  npm run test || exit 1 
  echo Run CLIENT tests 
  export npm_config_scope=client
  npm run test || exit 1
EOF

fi