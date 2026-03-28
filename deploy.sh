cd /home/vboxuser/catty-reminders-app
git pull origin lab1

echo "DEPLOY_REF=$(git rev-parse HEAD)" > .env

./build.sh
./test.sh

sudo systemctl restart catty-app