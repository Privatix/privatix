
# common

# decrypt bitrock license
wsl -e openssl aes-256-cbc -K $encrypted_bd83225125eb_key -iv $encrypted_bd83225125eb_iv -in ${TRAVIS_BUILD_DIR}/build/license.xml.enc -out ${TRAVIS_BUILD_DIR}/build/license.xml -d

ls ${TRAVIS_BUILD_DIR}/build/license.xml