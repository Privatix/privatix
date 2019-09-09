#
# Authentication
#
echo -e ">>> some magic"

echo -n $autotest1 >> ~/.ssh/travis_rsa_tests
base64 --decode --ignore-garbage ~/.ssh/travis_rsa_tests > ~/.ssh/id_rsa

chmod 600 ~/.ssh/id_rsa

echo -e ">>> Copy config"
mv -fv out/.travis/ssh-config ~/.ssh/config

ssh -T 89.38.99.85 hostname && wget http://ya.ru
#echo -e "LOGIN ssh"
#wget http://ya.ru/
