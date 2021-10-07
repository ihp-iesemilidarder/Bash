#!/bin/bash

########################	SYNTAX COMMAND        ########################
##############################################################################
#            networkScanner  <network>[/CIDR] [file]
#		Examples:
#			networkScanner.sh 192.168.0.0/24 /home/user/Desktop/ipsScan.txt
#				Scan the address ip 192.168.0.[0-255] and save it in the file /home/user/Desktop/ipsScan.txt
#			networkScanner.sh 10.0.15.0
#				Scan the address ip 10.0.15.[0-255] and NOT save it, print the result temporally
#			networkScanner.sh 2.50.128.5/16
#				Scan the address ip [2.50.0.0-2.50.255.255], thanks the CIDR


# Print a message in the screen
function messagePrint(){
	echo -e "\033[0;$2m[*]\033[0m $1."
}

# incremment the octet previous and initialize to zero the current octet
function updateOctetPre(){
	IP[$1]=$((${IP[$1]}+1)) # increment the octect previous
	IP[$2]=0 # initialize the current octet
	# if the loop for is in the last octet, then finish the process.
	if [[ $octetLoop = $3 ]];then
		if [[ $4 -ne "" ]];then
                        echo -e "\033[1;33m=================== \033[1;36mstatistics $addressNetwork\033[1;33m ===================\033[0m" >> $4
                        echo " Host up: $conn" >> $4
                        echo " Host down: $disconn" >> $4
                        echo " TOTAL::::>>>  $((conn+disconn))$output" >> $4
		else
			echo -e "\033[1;33m=================== \033[1;36mstatistics $addressNetwork\033[1;33m ===================\033[0m"$output
			echo " Host up: $conn"
			echo " Host down: $disconn"
			echo " TOTAL::::>>>  $((conn+disconn))$output"
		fi
		exit
	fi
}

# check the address IP, if this is up o down
function connection(){
	icmp=$(ping -c 2 $1)
	# IMPORTANT: You don´t touch the space before of percentage, else the check don´t work
	# successfully
	if [[ $icmp =~ " 0%" ]];then # is connected
		((conn++)) # incremment the hosts connected's count
		if [[ $# = 2 ]];then
			# if the file exists, then delete it, ONLY the first time, else will NOT delete it
			if [[ -f $2 && $deleted = 0 ]];then
				rm $2
				deleted=1
			else
				deleted=1
			fi
			echo $1 >> "$2"
			output=" saved in: \033[1;35m$2\033[0m"
		fi
		messagePrint "Host \033[1;33m$1\033[0m up$output" 32 $2
	elif [[ $icmp =~ " 100%" ]];then # is NOT connected
		((disconn++)) # incremment the hosts disconnected's count
		messagePrint "Host \033[1;33m$1\033[0m down" 31
	fi
}

# syntax IP address
#	192. 168.  1.   0
#       (1º) (2º) (3º) (4º)
# If the command contains one argumment, then I valid it
#	First, the argumment must be a IP address (with or within CIDR)
#	After this address IP, the last octet must be a zero (0) (4º)
#	And finally, the octets musn't be content a zero, in the first octet
if [[ $# -lt 1 || $# > 2 ]];then
	messagePrint "The program needs maximum three argumments" 31
	echo -e "\tscannerNetwork <network> <file_output>"
	exit
# if the first argumment is not IP and the last octet is not zero, print `The IP address isn't a network valid`
elif ! [[ $1 =~ ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2})$ && $(echo $1 | grep -E -o "^0") = "" ]];then
	# if the CIDR is not /8,/16,/24,/32
	if [[ ! $(echo $1 | grep -E -o "[0-9]{1,2}$") =~ [8|16|24|32] ]];then
		messagePrint "This IP is a network, but has a netmask of subnet. networkScanner doesn't configured for this networks' type" 31
	else
		messagePrint "The IP address isn't a network valid" 31
	fi
	exit
fi

echo ""
echo -e "\033[1;33m========================================="
echo -e "===          \033[1;36mnetworkScanner\033[1;33m           ==="
echo -e "=========================================\033[0m"
echo ""
echo -e "   scanning $1"
echo -e "============================"

# globals variables
octetLoop=0
conn=0
disconn=0
addressNetwork=$1
# boolean variable, for delete file, if this exists
deleted=0

# array IP=(192 168 0 1)
#  192     168     0     1
#  IP[0]   IP[1]  IP[2]  IP[3]

IFS="." read -ra IP <<< $1

# If in the address IP contains a slash, so, in the last element of IP list,
# split by /, and get the position 0
if [[ ${IP[3]} =~ "/" ]];then
	IFS="/" read -ra last_oct <<< ${IP[3]}
	IP[3]=${last_oct[0]}
fi
# Know how many `loop for` need to do for generate IP addresses
# If there is CIDR, look it, else, look the zeros of right
if [[ $(echo $addressNetwork | grep -E -o "[0-9]{1,2}$") -ne "" ]];then
	CIDR=$(echo $addressNetwork | grep -E -o "[0-9]{1,2}$")
	case $CIDR in
		8)
			octetLoop=3
			# As is a network /8, the three last octet will initilizare zero
			IP[1]=0
			IP[2]=0
			IP[3]=0
		;;
		16)
			octetLoop=2
			IP[2]=0
			IP[3]=0
		;;
		24)
			octetLoop=1
			IP[3]=0
		;;
		*)
			messagePrint "Your CIDR is not valid (/$CIDR)" 31
		;;
	esac
else
	# I Iterate all the IP address' elements
	for (( x=0;x <= $((${#IP[*]}-1));x++ ))
	do
		if [[ ${IP[x]} = 0 ]];then #                                                                                 current position. This is a zero, but, the follow is not it
			((octetLoop++)) #                                                                           ,------- so initilize to zero (octetLoop)
		# if the element specified is not zero and the variable `octetLoop` is more than zero  EXAMPLE : 10.0.5.0  octetLoop=1
		elif [[ ${IP[x]} =~ [0-9] && $octetLoop -gt 0 ]];then
			octetLoop=0
		fi
	done
fi

# first octet     [0].0.0.0
for (( n0=0;n0<=255;n0++ ))
do
	# second octet  0.[0].0.0
	for (( n1=0;n1<=255;n1++ ))
	do
		# third octet 0.0.[0].0
		for (( n2=0;n2<=255;n2++ ))
		do
			# fourth octet 0.0.0.[0]
			for (( n3=0;n3<=255;n3++ ))
			do
				# If the address IP is the network or broadcast, deny it
				if [[ $n3 -ne 0 && $n3 -ne 255 ]];then
					address=$(printf ".%s" ${IP[*]} | sed "s/^.//g") # join the all array's elements and delete the first letter
					# I do ping to address ip
					connection "$address" $2
				fi
				IP[3]=$((${IP[3]}+1))
			done
			#
			# EXAMPLE OF EXECUTE
			#	IP[2]=$((${IP[2]}+1))
			#	IP[3]=0
			#	if [[ $octetLoop = 1 ]];then
			#		exit
			#	fi
			updateOctetPre 2 3 1 $2
		done
		updateOctetPre 1 2 2

	done
	updateOctet 0 1 3
done
