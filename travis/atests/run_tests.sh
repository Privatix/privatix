#!/usr/bin/env bash

#
# ubuntu
#
travis_branch=${TRAVIS_BRANCH}
echo Travis branch: ${travis_branch}

if [ "$TRAVIS_OS_NAME" = "linux" ]; then
  echo Start running tests...
  ssh stagevm@89.38.99.188 export travis_branch=$travis_branch TELEGRAM_BOT_PASSWORD=$TELEGRAMPASSW '
  /bin/rm -rf /home/stagevm/tests/
  mkdir /home/stagevm/tests
  cd /home/stagevm/tests/
  git clone git@github.com:Privatix/privatix.git
  cd /home/stagevm/tests/privatix/
  git checkout ${travis_branch}
  echo git checkout ${travis_branch}
  #source /home/stagevm/tests/privatix/tests/integrational/helpers/setenv.sh || exit 1
  export TELEGRAM_BOT_USER=user
  export npm_config_scope=agent
  cd /home/stagevm/tests/privatix/tests/integrational 
  echo TELEGRAM_user $TELEGRAM_BOT_USER
  echo TEST_MODE $npm_config_scope
  npm install 
  npm run test 
  export npm_config_scope=client
  echo TEST_MODE $npm_config_scope
  npm run test
'
fi
