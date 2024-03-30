#!/bin/bash
#--------------------------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------------------------
UserSelection=""
ConnectionName=""
StaticIp=""
DefaultGatewayIp=""
PreferredDnsIp=""
#--------------------------------------------------------------------------------------------------
# Function to print main menu
#--------------------------------------------------------------------------------------------------
mainMenu(){
	UserSelection=""
	echo "===================================================================================="
	echo "                                     Main Menu                                      "
	echo "===================================================================================="
	echo "  1. List all network devices."
	echo "  2. List all network connections."
	echo "  3. List all active network connections."
	echo "  4. List current IP addresses."
	echo "  5. Configure Static IP."
	echo "  6. Configure DHCP."
	echo ""
	echo "  Enter 'Q' to terminate. "
	echo ""
	echo "===================================================================================="
	read -p "  Enter your selection: " UserSelection
	echo "===================================================================================="
}

#--------------------------------------------------------------------------------------------------
# Function to list all known network interfaces
#--------------------------------------------------------------------------------------------------
listNetworkInterfaces(){
	echo "===================================================================================="
	echo "                          All known network interfaces                              "
	echo "===================================================================================="
	nmcli dev status
}

#--------------------------------------------------------------------------------------------------
# Function to list all connections
#--------------------------------------------------------------------------------------------------
listNetworkConnections(){
        echo "===================================================================================="
        echo "                                 All connections                                    "
        echo "===================================================================================="

	nmcli con show
}

#--------------------------------------------------------------------------------------------------
# Function to list all IP addresses
#--------------------------------------------------------------------------------------------------
listNetworkAddresses(){
        echo "===================================================================================="
        echo "                          All known network ip addresses                            "
        echo "===================================================================================="
	ip addr
}

#--------------------------------------------------------------------------------------------------
# Function to list all active connections
#--------------------------------------------------------------------------------------------------
listAllActiveNetworkConnections(){
        echo "===================================================================================="
        echo "                          All active network interfaces                             "
        echo "===================================================================================="
	nmcli connection show --active
}


#--------------------------------------------------------------------------------------------------
# Method to evaluate the user selection and execute the desired command.
#--------------------------------------------------------------------------------------------------
executeCommand(){
	case $UserSelection in
		"1")
			# List all network interfaces
			listNetworkInterfaces
			;;
		"2")
			# List all network connections
			listNetworkConnections
			;;
		"3")
			# List all active connections
			listAllActiveNetworkConnections
			;;
		"4")
			# List all network addresses
			listNetworkAddresses
			;;
		"5")
			# Get connection details from user and setup static IP
			getStaticIpConnectionDetails
			;;
		"6")
			# Get DHCP connection details and Setup DHCP
			getDhcpConnectionDetails
			;;
		"q"|"Q")
			# If user keys in "Q" or "q", then terminate
			exit 0
			;;
		*)
			echo "Invalid input, please input a valid selection!"
			;;
	esac
}

#--------------------------------------------------------------------------------------------------
# Get user input for setting static ip connection
#--------------------------------------------------------------------------------------------------
getStaticIpConnectionDetails(){
	ConnectionName=""
	StaticIp=""
	DefaultGatewayIp=""
	PreferredDnsIp=""
	echo "===================================================================================="
	echo "                       Enter static ip connection Details                           "
	echo "===================================================================================="
	echo ""
	echo " Begin active connection listing:"
#	nmcli connection show --active
	listAllActiveNetworkConnections
	echo ""
	read -p "Connection name(Refer name command output above) : " ConnectionName
	read -p "Static IP to assign                              : " StaticIp
	read -p "Default gateway IP                               : " DefaultGatewayIp
	read -p "Preferred DNS IP                                 : " PreferredDnsIp
	echo ""
	echo "===================================================================================="
	echo " Connection and static IP details captured are:"
	echo " Connection Name        : "$ConnectionName
	echo " Static IP              : "$StaticIp
	echo " Default gateway IP     : "$DefaultGatewayIp
	echo " Preferred DNS IP       : "$PreferredDnsIp
	echo "===================================================================================="
	echo ""
	read -p " Plese confirm the details are correct (Y/N)? " verified
	if [ $verified = "Y" ] | [ $verified = "y" ]; then
		echo " Verification confirmed by user!"
		read -p " Proceed with setup (Y/N)? " setup
		if [ $setup = "Y" ] | [ $setup = "y" ]; then
		echo " Setup confirmed by user!"
			setupStaticIp
			exit 0
		else
              		echo " Setup declined by user!"
	                echo " Terminating..."
			exit 1
		fi
	else
		echo " Verification declined by user!"
		echo " Terminating..."
		exit 1
	fi
	echo "===================================================================================="
}

#--------------------------------------------------------------------------------------------------
# Function to setup static IP
#--------------------------------------------------------------------------------------------------
setupStaticIp(){
	echo " Setting up static IP configuration for connection: ""$ConnectionName""..."
	sudo nmcli con mod "$ConnectionName" ipv4.addresses "$StaticIp"
	sudo nmcli con mod "$ConnectionName" ipv4.gateway "$DefaultGatewayIp"
	sudo nmcli con mod "$ConnectionName" ipv4.dns "$PreferredDnsIp"
	sudo nmcli con mod "$ConnectionName" ipv4.method manual
	echo "===================================================================================="
	if [ $? -eq 0 ]; then
		echo " Static IP setup completed successfully!"
		sudo nmcli con up "$ConnectionName"
	echo "===================================================================================="
	listAllActiveNetworkConnections
#		nmcli con show --active
	echo "===================================================================================="
		exit 0
	else
		echo " Static IP setup failed for connection: ""$ConnectionName""..."
	echo "===================================================================================="
		exit 1
	fi
}

#--------------------------------------------------------------------------------------------------
# Get user input for setting connection profile to DHCP
#--------------------------------------------------------------------------------------------------
getDhcpConnectionDetails(){
        ConnectionName=""
        echo "===================================================================================="
        echo "                             Enter connection Details                               "
        echo "===================================================================================="
        echo ""
        echo " Begin active connection listing:"
 	listAllActiveNetworkConnections
#       nmcli connection show --active
        echo ""
        read -p " Connection name(Refer name command output above) : " ConnectionName
#	read -p "Default gateway IP                               : " DefaultGatewayIp
        echo ""
        echo "===================================================================================="
        echo ""
        echo "===================================================================================="
        echo " Connection and gateway details captured are:"
        echo " Connection Name        : "$ConnectionName
 #       echo " Default gateway IP     : "$DefaultGatewayIp
        echo "===================================================================================="
        echo ""
        read -p " Plese confirm the details are correct (Y/N)? " verified
        if [ $verified = "Y" ] | [ $verified = "y" ]; then
                echo " Verification confirmed by user!"
                read -p " Proceed with setup (Y/N)? " setup
                if [ $setup = "Y" ] | [ $setup = "y" ]; then
                echo " Setup confirmed by user!"
                        setupDhcp
                        exit 0
                else
                	echo " Setup declined by user!"
                	echo " Terminating..."
                	exit 1
                fi
        else
                echo " Verification declined by user!"
                echo " Terminating..."
                exit 1
        fi
        echo "===================================================================================="
}

#--------------------------------------------------------------------------------------------------
# Function to setup DHCP
#--------------------------------------------------------------------------------------------------
setupDhcp(){
	echo " Setting up DHCP configuration for connection: ""$ConnectionName""..." 
	sudo nmcli con mod "$ConnectionName" ipv4.address ""
	sudo nmcli con mod "$ConnectionName" ipv4.gateway ""
	sudo nmcli con mod "$ConnectionName" ipv4.dns ""
	sudo nmcli con mod "$ConnectionName" ipv4.method auto
        echo "===================================================================================="
        if [ $? -eq 0 ]; then
                echo " DHCP setup completed successfully!"
                sudo nmcli con up "$ConnectionName"
        echo "===================================================================================="
	listAllActiveNetworkConnections
#               nmcli con show --active
        echo "===================================================================================="
                exit 0
        else
                echo " DHCP setup failed for connection: ""$ConnectionName""..."
        echo "===================================================================================="
		exit 1
        fi
}

#--------------------------------------------------------------------------------------------------
# Main driver method
#--------------------------------------------------------------------------------------------------
#
# Loop main menu function till user presses exit
#
while true; do
	mainMenu
	executeCommand
done
