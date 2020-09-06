# Public_IP_Checker
This is a bash script for a public IP checker. 

The script requires a working e-mail service to run propperly. 
After the e-mail service / daemon is configured on the machine, the mailer.config is the place where you can add all the details for the script to run

The script is testing the public IP by accessing the https://ipinfo.io/ip web page
The script is appending an existing persistent log file where you can find all the details about the runtime 
Currently all changes are logged in a local SQL database (MariaDB is a testet and proven to work solution)
Also we are probing for the responsetime with a given IP. If the threashold is exceded a new w-mail notification will be sent 

Things to improve:
1) introduce the option for a monthly report 
2) make the database optional
3) brute force detection
4) much more efective ping probing  
