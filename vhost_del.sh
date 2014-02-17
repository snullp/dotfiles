#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ $(id -u) != "0" ]; then
	printf "Error: You must be root to run this script!"
	exit 1
fi

clear
MYSQL_ROOT_PWD=`cat /etc/mysql_root`

echo "Please enter account name:"
read -p "(Default vhost account: example):" VHOST_ACCOUNT
if [ -z $VHOST_ACCOUNT ]; then
	VHOST_ACCOUNT="example"
fi
OWNER=`ls -l /home/ | grep " $VHOST_ACCOUNT\$" | tr -s ' ' | cut -d ' ' -f3`
if [ $OWNER != 'www-data' -a $OWNER != $VHOST_ACCOUNT ]; then
echo "Owner mismatch"
exit 1
fi
echo "---------------------------"
echo "vhost account = $VHOST_ACCOUNT"
echo "---------------------------"
echo ""

MYSQL_DB_NAME="$VHOST_ACCOUNT"

echo "Please enter website domain:"
read -p "(e.g: example.com):" DOMAIN
if [ -z $DOMAIN ]; then
	DOMAIN="example.com"
fi
echo "---------------------------"
echo " Domain = $DOMAIN"
echo "---------------------------"
echo ""

echo "Enter yes to start delete vhost..."
echo "Or Ctrl+C cancel and exit ?"
read -p "Continue?(no) " IFCONT
if [ $IFCONT = "yes" ]; then

######################################################################

#	mysql -uroot -p$MYSQL_ROOT_PWD -e"DELETE FROM pureftpd.users WHERE users.User = '$VHOST_ACCOUNT';"
pure-pw userdel $VHOST_ACCOUNT -m

	mysql -uroot -p$MYSQL_ROOT_PWD -e"drop database $MYSQL_DB_NAME;Drop USER ${MYSQL_DB_NAME}@localhost;"


	rm -f /etc/apache2/sites-enabled/v-*${DOMAIN}.conf
	rm -rf /home/$VHOST_ACCOUNT
	rm -f /var/log/apache2/${DOMAIN}*

	echo "Restart apache......"
	service apache2 restart

echo ""
echo "===================== Delete completed ====================="
echo ""
echo "Vhost account: $VHOST_ACCOUNT"
echo "Website domain: $DOMAIN"
echo ""
echo "============================================================="
echo ""
fi
