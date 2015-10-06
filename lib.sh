#!/bin/sh

# include the json sh library
. /usr/share/libubox/jshn.sh

###################################
##### Library of SH Funcitons #####


#######################
## logging functions ##
bLogEnabled=0
logFile=`mktemp`

# function to setup logging
SetupLog () {
	if [ $bLogEnabled == 1 ]; then
		if [ -f $logFile ]; then
			rm -rf $logFile
		fi

		touch $logFile
	fi
}

# function to perform logging
#	argument 1: message to be logged
Log () {
	if [ $bLogEnabled == 1 ]; then
		echo "$1" >> $logFile
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


###########################
## rpcd script functions ##
# function to parse json params object
# 	returns a string via echo
_ParseArgumentsObject () {
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

		retArgumentString="$retArgumentString-$key $val "
	done

	echo "$retArgumentString"
}
