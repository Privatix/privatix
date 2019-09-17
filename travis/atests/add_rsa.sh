#!/usr/bin/env bash

openssl aes-256-cbc -K $encrypted_b77f5f8c0032_key -iv $encrypted_b77f5f8c0032_iv \
  -in ${TRAVIS_BUILD_DIR}/travis/atests/id_rsa.enc -out /tmp/id_rsa -d

eval "$(ssh-agent -s)"
mv -fv  ${TRAVIS_BUILD_DIR}/travis/atests/ssh-config \
        ~/.ssh/config

chmod 600 /tmp/id_rsa
ssh-add /tmp/id_rsa