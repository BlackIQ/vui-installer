#!/bin/bash

# Check that user is admin
if [ $(whoami) != "root" ]; then
  echo "This script must be run as root"
  exit 1
fi

dns="s.tfasoft.com"

apt update && apt upgrade -y

apt install python3 python3-pip nginx git -y

wget "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"

chmod +x install.sh

./install.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install v18

npm i -g pm2 serve create-next-app create-next-app nodemon
pip3 install pipenv

mkdir -p /app/vui
cd /app/vui

git clone https://github.com/BlackIQ/vui-client client
git clone https://github.com/BlackIQ/vui-api api

cd /app/vui/client
npm i

echo APP_PORT=8000 >> .env
echo DB_NAME=vui.db >> .env
echo API_KEY=secret >> .env

cd /app/vui/api
pipenv install --python $(which python3)

echo NEXT_PUBLIC_API_URL=http://${dns}/api >> .env.dev
echo NEXT_PUBLIC_API_KEY=secret >> .env.dev

npm run build

pm2 serve build --name vui-client --port 3000 --spa