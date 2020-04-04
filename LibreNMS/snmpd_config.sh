#!/bin/bash	
if [ $(id -u) -eq 0 ]; then

COMMUNITY='HOMELNMS'
LOCATION='@Home'
SYSCONTACT='PICARD Florian <picard.flo@gmail.com>'

# Install SNMPD
echo "+------------------------------------------------------------+"
echo "| Install SNMPD                                              |"
echo "+------------------------------------------------------------+"
echo ""

apt update
apt install snmpd --yes

echo "+------------------------------------------------------------+"
echo "| Configure SNMPD                                            |"
echo "+------------------------------------------------------------+"
echo ""

HOSTNAME=$(cat /etc/hostname)

cat >  /etc/snmp/snmpd.conf << __EOF__
com2sec readonly default $COMMUNITY
group MyROGroup v1 readonly
group MyROGroup v2c readonly
view all included .1 80
access MyROGroup "" any noauth exact all none none
sysName $HOSTNAME
sysLocation $LOCATION
sysContact $SYSCONTACT
__EOF__

echo "+------------------------------------------------------------+"
echo "| SNMP Extend for LIBRENMS                                   |"
echo "+------------------------------------------------------------+"
echo ""

#Distro
echo "Install SNMP script for .:distro:."
wget https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro -O /etc/snmp/distro
echo "extend .1.3.6.1.4.1.2021.7890.1 distro /etc/snmp/distro" >> /etc/snmp/snmpd.conf
chmod +x /etc/snmp/distro

#OS Update
echo "Install SNMP script for .:OS-Update:."
wget https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/osupdate -O /etc/snmp/osupdate
echo "extend osupdate /etc/snmp/osupdate" >> /etc/snmp/snmpd.conf
chmod +x /etc/snmp/osupdate

# Apache
# NOT ENABLE BY DEFAULT
echo "Install SNMP script for .:Apache Web Server:. - Disable by default"
apt-get install python-urlgrabber python-pycurl --yes
echo "Install SNMP script for OS-Update - Disable by Default"
wget https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/apache-stats.py -O /etc/snmp/apache-stats.py
echo "#extend apache /etc/snmp/apache-stats.py" >> /etc/snmp/snmpd.conf
chmod +x /etc/snmp/apache-stats.py

# MySQL
# NOT ENABLE BY DEFAULT
echo "Install SNMP script for .:MYSQL:. - Disable by Default"
wget https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/mysql -O /etc/snmp/mysql
echo "#extend mysql /etc/snmp/mysql" >> /etc/snmp/snmpd.conf
chmod +x /etc/snmp/mysql

cat >  /etc/snmp/mysql.cnf << \__EOF__
<?php
$mysql_user = 'root';
$mysql_pass = 'toor'
$mysql_host = 'localhost';
$mysql_port = 3306;
__EOF__

echo "+------------------------------------------------------------+"
echo "| restart SNMPD                                              |"
echo "+------------------------------------------------------------+"
echo ""

service snmpd restart
service snmpd status

else
echo "Vous devez etre root (ou Sudo) pour executer ce script"
exit 2
fi
