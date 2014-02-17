#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ $(id -u) != "0" ]; then
	echo "Error: You must be root to run this script!"
	exit 1
fi

clear
MYSQL_ROOT_PWD=`cat /etc/mysql_root`

echo "Please enter account name:"
read -p "(Default vhost account: example):" VHOST_ACCOUNT
if [ -z $VHOST_ACCOUNT ]; then
	VHOST_ACCOUNT="example"
fi
echo "---------------------------"
echo "vhost account = $VHOST_ACCOUNT"
echo "---------------------------"
echo ""

echo "Do you want to add a pureftpd user? (y/n)"
read -p "(Default: n):" ADD_FTPUSER
if [ -z $ADD_FTPUSER ]; then
	ADD_FTPUSER="n"
fi
if [ "$ADD_FTPUSER" = 'y' ]; then
	echo "Please enter your ftp account password:"
	read -p "(Default: 123456):" FTP_PWD
	if [ -z $FTP_PWD ]; then
		FTP_PWD="123456"
	fi
	echo "---------------------------"
	echo "Ftp password = $FTP_PWD"
	echo "---------------------------"
	echo ""
else
	echo "---------------------------"
	echo "You decided not to add FTP users!"
	echo "---------------------------"
	echo ""
fi

echo "Do you want to add MySQL DB? (y/n)"
read -p "(Default: n):" ADD_MYSQL_DB
if [ -z $ADD_MYSQL_DB ]; then
	ADD_MYSQL_DB="n"
fi
if [ "$ADD_MYSQL_DB" = 'y' ]; then
	MYSQL_DB_NAME="$VHOST_ACCOUNT"
	echo "Please enter your MySQL db password:"
	read -p "(Default: $FTP_PWD):" MYSQL_DB_PWD
	if [ -z $MYSQL_DB_PWD ]; then
		if [ -z $FTP_PWD ]; then
			MYSQL_DB_PWD="123456"
		else
			MYSQL_DB_PWD="$FTP_PWD"
		fi
	fi
	echo "---------------------------"
	echo "MySQL db name = $MYSQL_DB_NAME"
	echo "MySQL db password = $MYSQL_DB_PWD"
	echo "---------------------------"
	echo ""
else
	echo "---------------------------"
	echo " You decided not to add MySQL DB!"
	echo "---------------------------"
	echo ""
fi

echo "Please enter website domain:"
read -p "(e.g: example.com):" DOMAIN
if [ -z $DOMAIN ]; then
	DOMAIN="example.com"
fi
if [ -s /etc/apache2/sites-enabled/v-$DOMAIN.conf ]; then
	echo "---------------------------"
	echo "Note! $DOMAIN already is exist!"
	echo "---------------------------"
	echo ""
else
	echo "---------------------------"
	echo " Domain = $DOMAIN"
	echo "---------------------------"
	echo ""
fi

echo "Do you want to add subdomain? (y/n)"
read -p "(Default: n):" ADD_SUBDOMAIN
if [ -z $ADD_SUBDOMAIN ]; then
	ADD_SUBDOMAIN="n"
fi
if [ "$ADD_SUBDOMAIN" = 'y' ]; then
	echo "Please enter your subdomain:"
	read -p "(e.g: bbs):" SUBDOMAIN
	if [ -z $SUBDOMAIN ]; then
		SUBDOMAIN="bbs"
	fi
if [ -s /etc/apache2/sites-enabled/v-$SUBDOMAIN.$DOMAIN.conf ]; then
	echo "---------------------------"
	echo "Note! $SUBDOMAIN.$DOMAIN already is exist!"
	echo "---------------------------"
	echo ""
else
	echo "---------------------------"
	echo "Subdomain = $SUBDOMAIN"
	echo "---------------------------"
	echo ""
fi
else
	echo "---------------------------"
	echo "You don't want to add subdomain"
	echo "---------------------------"
	echo ""
fi

echo "Enter yes to start create vhost..."
echo "Or Ctrl+C cancel and exit ?"
read -p "Continue?(no) " IFCONT
if [ "$IFCONT" = "yes" ]; then

if [ ! -d "/home/$VHOST_ACCOUNT" ]; then
	mkdir -p /home/$VHOST_ACCOUNT/public_html
	chmod -R 750 /home/$VHOST_ACCOUNT
	echo $DOMAIN > /home/$VHOST_ACCOUNT/public_html/index.php
fi

if [ "$ADD_SUBDOMAIN" = 'y' ]; then
	mkdir -p /home/$VHOST_ACCOUNT/public_html/$SUBDOMAIN
	echo ${SUBDOMAIN}.${DOMAIN} > /home/$VHOST_ACCOUNT/public_html/$SUBDOMAIN/index.php
fi

ln -s /var/log/apache2/$DOMAIN.error.log /home/$VHOST_ACCOUNT/error.log
ln -s /var/log/apache2/$DOMAIN.access.log /home/$VHOST_ACCOUNT/access.log
	chown -R www-data:www-data /home/$VHOST_ACCOUNT
###################################  MySQL ###################################

if [ "$ADD_FTPUSER" = "y" ]; then
(echo $FTP_PWD; echo $FTP_PWD) | pure-pw useradd $VHOST_ACCOUNT -d /home/$VHOST_ACCOUNT -u www-data -m
fi

if [ "$ADD_MYSQL_DB" = "y" ]; then
	cat >/tmp/add_mysql_db<<-EOF
	create database $MYSQL_DB_NAME;
	grant all on ${MYSQL_DB_NAME}.* to $MYSQL_DB_NAME@localhost identified by '$MYSQL_DB_PWD';
	EOF
	cat /tmp/add_mysql_db | mysql -u root -p$MYSQL_ROOT_PWD
	rm -rf /tmp/add_mysql_db
fi

###################################  Apache ###################################

	if [ ! -s "/etc/apache2/sites-enabled/v-$DOMAIN.conf" ];then
		cat >>/etc/apache2/sites-enabled/v-$DOMAIN.conf<<-EOF
		<VirtualHost 198.23.129.114:80>
			ServerAdmin webmaster@$DOMAIN
			DocumentRoot "/home/$VHOST_ACCOUNT/public_html"
			ServerName $DOMAIN
			ServerAlias www.$DOMAIN
			ErrorLog "/var/log/apache2/$DOMAIN.error.log"
			CustomLog "/var/log/apache2/$DOMAIN.access.log" combined
			<Directory "/home/$VHOST_ACCOUNT/public_html">
				Options +Includes +Indexes
				php_admin_flag engine ON
				php_admin_value open_basedir "/home/$VHOST_ACCOUNT/public_html:/tmp:/proc"
			</Directory>
		</VirtualHost>

		EOF
		fi

	if [ "$ADD_SUBDOMAIN" = 'y' ]; then
		if [ ! -s "/etc/apache2/sites-enabled/v-${SUBDOMAIN}.${DOMAIN}.conf" ];then
			cat >>/etc/apache2/sites-enabled/v-${SUBDOMAIN}.${DOMAIN}.conf<<-EOF
			<VirtualHost 198.23.129.114:80>
				ServerAdmin webmaster@$DOMAIN
				DocumentRoot "/home/$VHOST_ACCOUNT/public_html/$SUBDOMAIN"
				ServerName $SUBDOMAIN.$DOMAIN
				ErrorLog "/var/log/apache2/$DOMAIN.error.log"
				CustomLog "/var/log/apache2/$DOMAIN.access.log" combined
				<Directory "/home/$VHOST_ACCOUNT/public_html/$SUBDOMAIN">
					Options +Includes +Indexes
					php_admin_flag engine ON
					php_admin_value open_basedir "/home/$VHOST_ACCOUNT/public_html/$SUBDOMAIN:/tmp:/proc"
				</Directory>
			</VirtualHost>

			EOF
			fi

		fi

	echo "Restart apache......"
	service apache2 restart

echo ""
echo "===================== Install completed ====================="
echo ""
echo "Your account: $VHOST_ACCOUNT"
echo "Your domain: $DOMAIN"
echo "Your domain directory: /home/$VHOST_ACCOUNT/"
if [ "$ADD_SUBDOMAIN" = 'y' ]; then
echo "Your subdomain: $SUBDOMAIN"
echo "Your subdomain directory: /home/$VHOST_ACCOUNT/public_html/$SUBDOMAIN"
fi
echo ""
echo "httpd config file at: /etc/apache2/sites-enabled/v-$DOMAIN.conf"
echo ""
echo "============================================================="
echo ""
fi
