#!/usr/bin/env bash

#
# ubuntu
#
travis_branch=${TRAVIS_BRANCH}
echo Travis branch: ${travis_branch}

if [ "$TRAVIS_OS_NAME" = "linux" ]; then
  echo Start running tests...
  ssh stagevm@89.38.99.188 << 'EOF' || exit 1
  #tests_dir=/home/stagevm/tests
  /bin/rm -rf /home/stagevm/tests/
  mkdir /home/stagevm/tests
  cd /home/stagevm/tests/
  git clone git@github.com:Privatix/privatix.git
  cd /home/stagevm/tests/privatix/
  git checkout ${travis_branch}
  echo git checkout ${travis_branch}
  #source /home/stagevm/tests/privatix/tests/integrational/helpers/setenv.sh || exit 1
  export TELEGRAM_BOT_USER=user
  export TELEGRAM_BOT_PASSWORD=$TELEGRAMPASSW
  export npm_config_scope=both
  cd /home/stagevm/tests/privatix/tests/integrational || exit 1
  npm install || exit 1
  npm run test || exit 1 
EOF

fi
