#!/bin/sh

# include the json sh library
. /usr/share/libubox/jshn.sh

###################################
##### Library of SH Funcitons #####



#######################
## device functions  ##

DEVICE_OMEGA="Onion Omega"
DEVICE_OMEGA2="Onion Omega2"
DEVICE_OMEGA2P="Onion Omega2+"

# find the device type
# 	returns device model in text (via echo)
GetDeviceType () {
	jsonRet=$(ubus call system board)

	# parse the response
	json_load "$jsonRet"
	json_get_var deviceType "model"

	echo "$deviceType"
}

#######################
## logging functions ##
bLogEnabled=0
logFile=""

# function to setup logging
SetupLog () {
	if [ $bLogEnabled == 1 ]; then
		if [ "$logFile" == "" ]; then
			# create the log file
			logFile=`mktemp`
			touch $logFile
		fi
	fi
}

# function to perform logging
#	argument 1: message to be logged
Log () {
	if [ $bLogEnabled == 1 ]; then
		SetupLog
		echo "$1" >> $logFile
	fi
}

# function to delete empty log files
# DEPRECATED: log files are no longer created if logging not enabled
CloseLog () {
	if 	[ $bLogEnabled == 0 ] &&
		[ -f $logFile ];
	then
		rm -rf $logFile
	fi
}


#######################
## web functions     ##

# download from a url
# 	argument 1 - the url
# 	argument 2 - optional destination filename
# returns: (via echo)
#	0:	download successful
#	1: 	download failed
#	resp variable: contains output of wget command
DownloadUrl () {
	# handle the output destination
	local OUTPUT=""
	if [ "$2" != "" ]; then
		OUTPUT="-O $2"
	fi

	# perform the wget
	resp=$(wget -S $OUTPUT "$1" 2>&1)

	# check if successful
	local ret=$(echo "$resp" | grep 'HTTP/1.1 200 OK')

	# return a value
	if [ "$ret" != "" ]; then
		echo "0"
	else
		echo "1"
	fi
}



#################################
## number conversion functions ##
# convert hex to decimal
#	argument 1 - hex value
# 	returns hex via echo
HexToDec () {
	# check if hex has 0x at start
	hex=$1
	grep=`echo $hex | grep "0x"`
	if [ "$grep" == "" ]; then
		# add 0x 
		hex=`echo $1 | sed -e 's/^/0x/'`
	fi

	# convert hex to decimal
	dec=$(($hex))

	# return the decimal value
	echo "$dec"
}

# convert hex to duty cycle (decimal, out of 100)
#	argument 1 - hex value (expecting 0x12 format)
# 	returns output via echo
HexToDuty () {
	# convert hex to decimal
	decimal=$( HexToDec $1 )

	# find the duty %
	duty=$(($decimal*100/255))

	#return the duty
	echo "$duty"
}

# flip duty cycle polarity
#	argument 1 - duty cycle (0-100)
#	returns output via echo
FlipDutyPolarity () {
	# flip the polarity
	ret=$((100-$1))

	# return the new duty
	echo "$ret"
}

# performs hex to duty conversion for exp led
# 	argument 1 - hex value (0x12 format)
# 	returns duty via exho
ExpLedHexToDuty () {
	# hex to duty
	duty=$( HexToDuty $1 )

	# flip the duty polarity
	dutyFlip=$( FlipDutyPolarity $duty )

	# return the duty
	echo "$dutyFlip"
}


###############################
## process related functions ##
# function to get process info of any processes matching input
# 	argument1: process name
# 	argument2: optional string to ignore
#	returns ps output via echo
_getPs () {
	# find any matching processes
	local process=`ps | grep -v grep | grep $1`

	#optional ignore
	if [ "$2" != "" ]; then
		process=`ps | grep -v grep | grep $1 | grep -v $2`
	fi

	echo "$process"
}

# function to get pids of any processes matching input
#	argument1: process name
# 	argument2: optional string to ignore
#	returns a string of space-separated pids of matching processes via echo
_getPids () {
	# find any matching processes
	local pids=`ps | grep -v grep | grep $1 | sed -e 's/^ \([0-9]*\).*$/\1/' | tr '\n' ' '`

	#optional ignore
	if [ "$2" != "" ]; then
		pids=`ps | grep -v grep | grep $1 | grep -v $2 | sed -e 's/^ \([0-9]*\).*$/\1/' | tr '\n' ' '`
	fi

	echo "$pids"
}


###########################
## rpcd script functions ##
# function to parse json params object
#	argument1: if it is 'nodash', do not add a dash to the keys
# 	returns a string via echo
_ParseArgumentsObject () {
	# check if dash required
	local dash="-"
	if [ "$1" == "nodash" ]; then
		dash=""
	fi

	local retArgumentString=""

	# select the arguments object
	json_select params
	
	# read through all the arguments
	json_get_keys keys

	for key in $keys
	do
		# get the key value
		json_get_var val "$key"
		
		# specific key modifications
		if 	[ "$key" == "ssid" ] ||
			[ "$key" == "password" ];
		then
			# add double quotes around ssid and password
			val="\"$val\""
		fi

		# wrap value in double quotes if it contains spaces
		if 	[ "$(echo $val | grep ' ')" != "" ] ||
			[ "$(echo $val | grep '\n')" != "" ]
		then
			val="\"$val\""
		fi

		retArgumentString="$retArgumentString$dash$key $val "
	done

	echo "$retArgumentString"
}
