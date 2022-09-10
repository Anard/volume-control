#!/bin/bash
STEP=5; unset FORCE modif
SOUND="/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
if [ $# -eq 0 ]; then echo "Missing argument, type change-volume --help for more information" && exit 255; fi
exit_wrong_param() {
	echo "Modification have ever been set, exiting" && exit 2
}
while [ $# -gt 0 ]; do
	case $1 in
	 -fi|-if) 
	 	if [ $modif ]; then
	 		exit_wrong_param
	 	else
	 		modif="+${STEP}%"
	 		FORCE=1
	 	fi
	 	;;
	 		
	 -i|--increase)
	 	[ $modif ] && exit_wrong_param || modif="+${STEP}%";;
	 -d|--decrease)
	 	[ $modif ] && exit_wrong_param || modif="-${STEP}%";;
	 -f|--force)
	 	FORCE=1;;
	 -h|--help)
	 	help=$( cat << HELP
Script for increasing/decreasing sound
Usage : change-volume OPTION [OPTION] [...]

OPTIONS :
        -h|--help	Print this help and exit

        -i|--increase    Increase volume
        -d|--decrease    Decrease volume
        -f|--force    	 With -i, force increasing volume even if result in volume greater than 100%

HELP
)
	 	echo "${help}"
	 	exit 0
	 	;;
	 	
	 *)
	 	echo "Unknown option $1, type change-volume --help for more information, exiting..."
	 	exit 1
	 	;;
	esac
	shift
done

# First unmute, then change volume, take modification in argument
modif_volume() {
	if [ $# -eq 0 ]; then return 255; fi
	pactl set-sink-mute @DEFAULT_SINK@ false
	pactl set-sink-volume @DEFAULT_SINK@ $1
	pactl play-sample volume
	return 0
}
cur_volume=$( pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' )
cur_volume=${cur_volume%?}
pactl upload-sample "${SOUND}" volume
case $modif in
	+*)
		let max=( 100-$STEP )
		if [ $cur_volume -le 100 ] && [ $cur_volume -gt $max ]; then
			[ $FORCE ] && modif_volume $modif || modif_volume 100%
		else
			modif_volume $modif
		fi
		unset max
		;;
	*)
		[ $cur_volume -lt $STEP ] && modif_volume 0% || modif_volume $modif
		;;
esac
pactl remove-sample volume
unset cur_volume FORCE STEP SOUND
exit 0
