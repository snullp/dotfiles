#!/bin/sh

sudo apt-get install curl

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
echo "export EDITOR=vim" >> ~/.bashrc
curl https://raw.githubusercontent.com/snullp/dotfiles/master/vimrc -o ~/.vimrc
fi

echo "Bash PS1?"
read  yn
if [ "$yn" = "y" ]; then
    cat >>~/.bashrc <<"EOF"
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    HOSTCOLOR=31
else
    HOSTCOLOR=32
fi
export PS1="<\[\033[0;${HOSTCOLOR}m\]\h\[\033[0m\]:\[\033[0;37m\]\u\[\033[0m\]> \j:\$? [\A] \w \n\$ "
EOF
fi
