#!/bin/sh

echo "Pub Key?"
read  yn
if [ "$yn" = "y" ]; then
mkdir ~/.ssh
chmod 700 ~/.ssh
curl http://nyc.bigsquirrel.me/~snullp/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
fi

echo "Vim?"
read  yn
if [ "$yn" = "y" ]; then
sudo apt-get install vim
echo "EDITOR = vim" >> ~/.bashrc
curl https://raw.githubusercontent.com/snullp/dotfiles/master/vimrc -o ~/.vimrc
fi

echo "Bash PS1?"
read  yn
if [ "$yn" = "y" ]; then
echo "PS1 = !!!!!!!!" >> ~/.bashrc
fi
