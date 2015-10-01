#!/bin/sh

###################################
##### Library of SH Funcitons #####

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
