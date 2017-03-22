#!/bin/bash

WORK=25
PAUSE=5
PAUSE_LONG=30
PAUSE_LONG_CYCLE=4
MUTE=false

show_help() {
	cat <<-END
		usage: potato [-m] [-w m] [-b m] [-l m] [-c n] [-h]
		    -m: mute -- don't play sounds when work/break is over
		    -w m: let work periods last m minutes (default is 25)
		    -b m: let break periods last m minutes (default is 5)
		    -l m: let long break periods last m minutes (default is 30)
		    -c n: let long break happend after n work cycles (default is 4)
		    -h: print this message

		    SIGINT: skip countdown
		    2xSIGINT within 1s: terminate
	END
}

countdown_skip() {
	echo
	sleep 1 || exit 1
}

countdown() {
	TIME=$1
	TYPE=$2

	time_left="\r%im left of %s "

	for ((i=$TIME; i>0; i--))
	do
		printf "$time_left" $i $TYPE
		sleep 1m
	done
}

notify_sound() {
	echo -e "\a"
	! $MUTE && aplay /usr/share/sounds/speech-dispatcher/test.wav &>/dev/null
}

trap countdown_skip SIGINT

while getopts :sw:b:l:c:m opt; do
	case "$opt" in
	m)
		MUTE=true
	;;
	w)
		WORK=$OPTARG
	;;
	b)
		PAUSE=$OPTARG
	;;
	l)
		PAUSE_LONG=$OPTARG
	;;
	c)
		PAUSE_LONG_CYCLE=$OPTARG
	;;
	h|\?)
		show_help
		exit 1
	;;
	esac
done

for ((j=1;;j++))
do
	countdown $WORK "work" &
	wait
	notify_sound
	echo "Work over"
	read
	
	
	if [ $(($j%$PAUSE_LONG_CYCLE)) -eq 0 ] 
	then
		BREAK=$PAUSE_LONG
	else
		BREAK=$PAUSE
	fi

	countdown $BREAK "break" &
	wait
	notify_sound
	echo "Break over"
	read
done
