#!/bin/bash
VERSION=1.03.8
BUILD_DATE=29.06.2020
PARAM_1="$1"
PARAM_2="$2" 
BUFF=""
#general syntax ./mailer.sh <dedicated_hostname> <optional_options> <path_to_config_file>
#mailer.sh Blynk -force /home/pi/config.mailer
#============================= PRECHECKS =============================
if [ -s "$PARAM_2/config.mailer" ] || [ -s "$3/config.mailer" ] || [ -s config.mailer ] 
then
	if [ -s config.mailer ]
	then
	LOG_FILE=$(cat config.mailer | grep "LOG_FILE" | cut -d "=" -f 2 )
	BUFF=""
	fi
	if [ -s "$PARAM_2/config.mailer" ]
	then
	LOG_FILE=$(cat "$PARAM_2/config.mailer" | grep "LOG_FILE" | cut -d "=" -f 2 )
	BUFF=$PARAM_2
	fi
	if [ -s "$3/config.mailer" ]
	then
	LOG_FILE=$(cat $3/config.mailer | grep "LOG_FILE" | cut -d "=" -f 2 )
	BUFF=$3
	fi
else
echo "$(date): ERROR: Script configuration file is missing " 
exit 1
fi
if [ -z "$(whereis mail | cut -d ":" -f 2)" ]
then
echo "$(date): ERROR: mail command not found hence script is exiting..." >> $LOG_FILE
exit 2
else
	echo "$(date): INFO: Start" >> $LOG_FILE
	if [ -z "$(dpkg --get-selections | grep msmtp)" ]
	then
	echo "$(date): WARNING: msmtp packages are missing" >> $LOG_FILE
	fi
	if [ -z "$(dpkg --get-selections | grep mailutils)" ]
	then
	echo "$(date): WARNING: mailutils packages are missing" >> $LOG_FILE
	fi
	if [ -s "$(msmtp --version | grep "System configuration" | cut -d ":" -f 2 | cut -d " " -f 2)" ]
	then
	echo "$(date): INFO: msmtp file configuration file found" >> $LOG_FILE
		else 
	echo "$(date): WARNING: msmtp file content is missing" >> $LOG_FILE
	fi
fi
#=====================================================================
if [ "$BUFF" = "" ]
then
MAIL_BODY=$(cat config.mailer | grep "MAIL_BODY" | cut -d "=" -f 2 )
IP_BUFFER=$(cat config.mailer | grep "IP_BUFFER" | cut -d "=" -f 2 )
ATTACK_CONFIG=$(cat config.mailer | grep "ATTACK_CONFIG" | cut -d "=" -f 2 )
E_MAIL=$(cat config.mailer | grep "E_MAIL" | cut -d "=" -f 2 )
IP_TO_TEST=$(cat config.mailer | grep "IP_TO_TEST" | cut -d "=" -f 2 )
PING_THR=$(cat config.mailer | grep "PING_THR" | cut -d "=" -f 2 )
SQL_BUFFER=$(cat config.mailer | grep "SQL_BUFFER" | cut -d "=" -f 2 )
SQL_USER=$(cat config.mailer | grep "SQL_USER" | cut -d "=" -f 2 )
SQL_PASS=$(cat config.mailer | grep "SQL_PASS" | cut -d "=" -f 2 )
DB_NAME=$(cat config.mailer | grep "DB_NAME" | cut -d "=" -f 2 )
NUME_TABELA=$(cat config.mailer | grep "NUME_TABELA" | cut -d "=" -f 2 )
else
MAIL_BODY=$(cat $BUFF/config.mailer | grep "MAIL_BODY" | cut -d "=" -f 2 )
IP_BUFFER=$(cat $BUFF/config.mailer | grep "IP_BUFFER" | cut -d "=" -f 2 )
ATTACK_CONFIG=$(cat $BUFF/config.mailer | grep "ATTACK_CONFIG" | cut -d "=" -f 2 )
E_MAIL=$(cat $BUFF/config.mailer | grep "E_MAIL" | cut -d "=" -f 2 )
IP_TO_TEST=$(cat $BUFF/config.mailer | grep "IP_TO_TEST" | cut -d "=" -f 2 )
PING_THR=$(cat $BUFF/config.mailer | grep "PING_THR" | cut -d "=" -f 2 )
SQL_BUFFER=$(cat $BUFF/config.mailer | grep "SQL_BUFFER" | cut -d "=" -f 2 )
SQL_USER=$(cat $BUFF/config.mailer | grep "SQL_USER" | cut -d "=" -f 2 )
SQL_PASS=$(cat $BUFF/config.mailer | grep "SQL_PASS" | cut -d "=" -f 2 )
DB_NAME=$(cat $BUFF/config.mailer | grep "DB_NAME" | cut -d "=" -f 2 )
NUME_TABELA=$(cat $BUFF/config.mailer | grep "NUME_TABELA" | cut -d "=" -f 2 )
fi
MOD="RUNNING"
IP_OLD=""
FAILEDATEMPT=$(cat /var/log/auth.log | grep failure | wc -l)
ATTACK_ALERT=$(grep "$(date +"%b %d")" /var/log/auth.log | grep -i failure | wc -l)
ATTACK_SOURCE=$(grep "$(date +"%b %d")" /var/log/auth.log | grep -i failure)
IP_VALUE=$(curl -s 'https://ipinfo.io/ip')
VALID_IP="ADEVARAT"
PING_AVG=""
#======================== DEBUG ===================
#echo $MAIL_BODY
#echo $IP_BUFFER
#echo $ATTACK_CONFIG
#echo $E_MAIL
#echo $IP_TO_TEST
#echo $PING_THR
#echo $LOG_FILE
#==================================================
echo "$(date): INFO: IP checker script is executing ..." >> $LOG_FILE
if [ "$PARAM_2" = "-v" ] 
then
echo "Version $VERSION"
echo "Log file can be found $LOG_FILE"
echo "IP buffer text can be found $IP_BUFFER"
exit  
fi

if [ "$PARAM_2" =  "-force" ] # parametru pentru testat mail-uri 
then
echo "$(date): INFO: The force command has been used" >> $LOG_FILE
echo "INFO: The force option has been used" >> $MAIL_BODY
fi
#================================ IP form check ================================
#192.168.  1.  2
#  5. 10.122.223
i=$(echo $IP_VALUE | tr -dc '.' | wc -m)
if [ $i != 3 ] # o adresa de IP trebuie sa aiba exact 3 puncte si 4 seturi de caractere
then 
 VALID_IP="FALSE"
 else
	for j in 1 2 3 4 #nici unul din cele 4 seturi de caractere separate prin punct nu trebuie sa fie mai mare de 256 
		do
			if [ $(echo $IP_VALUE | cut -d "." -f $j) -gt 256 ]
			then
			VALID_IP="FALSE"
			break
			fi
		done
fi 
#===============================================================================
if [ -z "$IP_VALUE" ] || [ $VALID_IP = "FALSE" ] 
then
echo "$(date): ERROR: Current IP value retrieval has failed" >> $LOG_FILE
echo "$(date): ERROR: The error is related to https://ipinfo.io/ip response " >> $LOG_FILE
echo "$(date): ERROR: SCRIPT TERMINATED "
echo >> $LOG_FILE
echo "$(date): INFO: Version $VERSION" >> $LOG_FILE
echo "$(date): INFO: Script run completed. " >> $LOG_FILE
echo >> $LOG_FILE
echo >> $LOG_FILE
exit
else 
echo "$(date): INFO: Current IP value retrieval was successful " >> $LOG_FILE
echo "$(date): INFO: Current IP value is $IP_VALUE " >> $LOG_FILE
fi
if [ $FAILEDATEMPT -gt 1 ]
then 
echo "Please see the below failed attempts:" >> $LOG_FILE
cat /var/log/auth.log | grep failure >> $LOG_FILE
fi
if [ $ATTACK_ALERT -gt 3 ] && [ "$(date +"%b %d")" != "$(cat $ATTACK_CONFIG)" ]
then
MOD="ALERT"
echo "$(date): ALERT: Detected" >> $LOG_FILE
echo "$(date): INFO: Composing alert mail" >> $LOG_FILE
echo "Number of failed attepts is $ATTACK_ALERT" >> $MAIL_BODY
echo "Attack source:">> $MAIL_BODY
grep "$(date +"%b %d")" /var/log/auth.log | grep -i failure >> $MAIL_BODY
echo $(date +"%b %d") > $ATTACK_CONFIG
fi
if [ -s "$IP_BUFFER" ]
then
IP_OLD=$(cat "$IP_BUFFER")
echo "$(date): INFO: System  IP value is $IP_OLD " >> $LOG_FILE
	if [ "$IP_OLD" != "$IP_VALUE" ]
	then
		echo "Current IP value is as seen below:" >> $MAIL_BODY
		echo $IP_VALUE >> $MAIL_BODY
		echo "$(date): INFO: Adding the new IP address to the mail body " >> $LOG_FILE
		echo >> $MAIL_BODY
		echo "System  IP value was as seen below:">> $MAIL_BODY
		echo $IP_OLD >> $MAIL_BODY
		echo "$(date): INFO: Adding the system IP address to the mail body " >> $LOG_FILE
		echo $IP_VALUE > $IP_BUFFER
		echo "$(date): INFO: Adding the current IP ( $IP_VALUE ) to the buffer text  " >> $LOG_FILE
	else
		if [ "$PARAM_2" =  "-force" ]
		then
		echo "INFO: No changes in the IP address" >> $MAIL_BODY
		echo "System  IP value was as seen below:">> $MAIL_BODY
		echo $IP_OLD >> $MAIL_BODY
		fi
		echo "$(date): INFO: No changes in the IP address " >> $LOG_FILE
	fi
else
echo "$(date): WARNING: The buffer text file was not found" >> $LOG_FILE
echo $IP_VALUE > $IP_BUFFER
echo "$(date): INFO: Adding the new IP address to the buffer text file " >> $LOG_FILE
echo "Current IP value is as seen below:" >> $MAIL_BODY
echo $IP_VALUE >> $MAIL_BODY
echo "$(date): INFO: Adding the new IP address to the mail body " >> $LOG_FILE
echo >> $MAIL_BODY
fi
#============================== Latency test ==============================
PING_AVG=$(ping -c 10 $IP_TO_TEST | grep "avg/max" | cut -d "=" -f 2 | cut -d "/" -f 2 | cut -d "." -f 1 )
if [ $PING_AVG -gt $PING_THR ] 
then
echo "$(date): ERROR: Latency value reached! Latency value is $PING_AVG" >> $LOG_FILE
echo "ERROR: Latency value reached! Latency value is $PING_AVG" >> $MAIL_BODY
echo "Current IP value is:  $IP_VALUE" >> $MAIL_BODY
 else
echo -e "$(date): INFO: Latency value is $PING_AVG" >> $LOG_FILE
fi
#==========================================================================
if [ -s "$MAIL_BODY" ]
then
#================================== Database insert =======================
echo "$(date): INFO: Writing to the database..." >> $LOG_FILE

echo "INSERT INTO $NUME_TABELA (ip, data_inregistrare, ping) VALUES (\"$IP_OLD\",\"$(date "+%Y-%m-%d %H:%M:%S")\", $PING_AVG);" > $SQL_BUFFER
#mysql -uroot -padmin Info
#select * from informatii group by ip order by id;
sudo -u root mysql -u $SQL_USER -p$SQL_PASS $DB_NAME < $SQL_BUFFER

#sudo -u root mysql --user=root --password=admin --execute INSERT INTO informatii (ip, data_inregistrare, ping) VALUES ("$IP_OLD","$DATE","$PING_AVG" ) Info;

echo "$(date): INFO: Writing to the database compelte..." >> $LOG_FILE
#==========================================================================
fi

############ FOOTER
if [ -s "$MAIL_BODY" ]
then
echo "$(date): INFO: Adding footer information to the mail body " >> $LOG_FILE
echo >> $MAIL_BODY
echo "Uptime details: ">> $MAIL_BODY
uptime >> $MAIL_BODY
echo >> $MAIL_BODY
echo "User details: ">> $MAIL_BODY
echo >> $MAIL_BODY
who >> $MAIL_BODY
echo >> $MAIL_BODY
date >> $MAIL_BODY
echo >> $MAIL_BODY
echo >> $MAIL_BODY
echo "Script version is: $VERSION" >> $MAIL_BODY
echo "$(date): INFO: Sending mail... " >> $LOG_FILE
cat $MAIL_BODY |  mail -s "$PARAM_1:$MOD" $E_MAIL 2>> $LOG_FILE
echo "$(date): INFO: Sending mail complete " >> $LOG_FILE
echo "$(date): INFO: Removing mail body file... " >> $LOG_FILE
rm $MAIL_BODY 2>> $LOG_FILE
echo "$(date): INFO: Removing mail body file complete " >> $LOG_FILE
fi
echo "$(date): INFO: Uptime details: ">> $LOG_FILE
uptime >> $LOG_FILE
echo "$(date): INFO: User details: ">> $LOG_FILE
who >> $LOG_FILE
echo >> $LOG_FILE
echo "$(date): INFO: Version $VERSION" >> $LOG_FILE
echo "$(date): INFO: Script run completed. " >> $LOG_FILE
echo >> $LOG_FILE
exit 0