#
# Authentication
#
echo -e ">>> some magic"

echo -n $autotest1 >> /tmp/travis_rsa_tests
base64 --decode --ignore-garbage /tmp/travis_rsa_tests > /tmp/id_rsa
mkdir ~/.ssh
ssh-add /tmp/id_rsa
chmod 600 ~/.ssh/id_rsa

echo -e ">>> Copy config"
#mv -fv out/.travis/ssh-config ~/.ssh/config

ssh stagevm@89.38.99.85 hostname && wget http://ya.ru
#echo -e "LOGIN ssh"
#wget http://ya.ru/
