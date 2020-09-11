# Public_IP_Checker
This is a bash script for a public IP return.

# USERS
The script from this solution is intended from home users to small business in order to monitor the public IP of a certain network.
This is a alternative to a Dynamic DNS or a VPN (which in turn can be expensive or not available in the area where the network is located)

# Why would you need your public IP?
If you want to manage you network remotely you will need one of the above ways to access your network (VPN / Dynamic DNS / Public IP)
Combined with a port forwarding, this combo (public IP and port) will grant you untethered access to your network from abroad. 

# Example of use
- 3D printers and CNC machines that can work in a remote location with minimum human interaction 
- Whether stations 
- Smart homes 
- Smart gardens 
- Other IoT projects 


The script requires a working e-mail service to run properly. 
After the e-mail service / daemon is configured on the machine, the mailer.config is the place where you can add all the details for the script to run

The script is testing the public IP by accessing the https://ipinfo.io/ip web page
The script is appending an existing persistent log file where you can find all the details about the runtime 
Currently all changes are logged in a local SQL database (MariaDB is a tested and proven to work solution)
Also we are probing for the response time with a given IP. If the threshold is exceeded a new w-mail notification will be sent 

Things to improve:
1) introduce the option for a monthly report - working on it 
2) make the database optional - done
3) brute force detection (better algorithm)
4) much more effective ping probing  
5) ping probing optional - done 
