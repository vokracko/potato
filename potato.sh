#!/bin/bash

WORK=25
PAUSE=5
PAUSE_LONG=30
PAUSE_LONG_CYCLE=4
INTERACTIVE=true
MUTE=false

show_help() {
	cat <<-END
		usage: potato [-s] [-m] [-w m] [-b m] [-l m] [-c n] [-h]
		    -s: simple output. Intended for use in scripts
		        When enabled, potato outputs one line for each minute, and doesn't print the bell character
		        (ascii 007)

		    -m: mute -- don't play sounds when work/break is over
		    -w m: let work periods last m minutes (default is 25)
		    -b m: let break periods last m minutes (default is 5)
		    -l m: let long break periods last m minutes (default is 30)
		    -c n: let long break happend after n work cycles (default is 4)
		    -h: print this message
	END
}

while getopts :sw:b:l:c:m opt; do
	case "$opt" in
	s)
		INTERACTIVE=false
	;;
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

time_left="%im left of %s "

if $INTERACTIVE; then
	time_left="\r$time_left"
else
	time_left="$time_left\n"
fi

for ((j=1;;j++))
do
	for ((i=$WORK; i>0; i--))
	do
		printf "$time_left" $i "work"
		sleep 1m
	done

	! $MUTE && aplay /usr/share/sounds/speech-dispatcher/test.wav &>/dev/null

	if $INTERACTIVE; then
		echo -e "\a"
		echo "Work over"
		read
	fi

	if [ $(($j%$PAUSE_LONG_CYCLE)) -eq 0 ] 
	then
		BREAK=$PAUSE_LONG
	else
		BREAK=$PAUSE
	fi

	for ((i=$BREAK; i>0; i--))
	do
		printf "$time_left" $i "pause"
		sleep 1m
	done
	! $MUTE && aplay /usr/share/sounds/speech-dispatcher/test.wav &>/dev/null
	if $INTERACTIVE; then
		echo -e "\a"
		echo "Pause over"
		read
	fi
done
