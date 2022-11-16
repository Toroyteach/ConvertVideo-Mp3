#!/bin/bash

#Author: Toroyteach
#Desc: This script converst videos to mp3 files.
## does so buy creating a folder in the same directory of the
## script file and places the converted audio file inside it
## retaining the name if the video( spaces will be removed).
#Reqiurements: this script requires FFMPEG and LAME packages
## to be installed on your system..You also need super user
## prvileges to 2un it

##check if script was run with su priviledge
if [[ $(id -u) -ne 0 ]]; then
	echo "You need Super User priviledges to run this script"
	exit 1
fi

##check if FFMPEG and LAME packages are installed
FFMPEG_PACKAGE='dpkg-query -l | grep ffmpeg'
LAME='dpkg-query -l | grep lame'

if [[ -z "$FFMPEG_PACKAGE" ]]; then
	echo "FFMPEG is not installed. Please instal this package to continue"
	echo "Requesting download persission"

	read -p "Would you like to download FFMPEG? " -n 1 -r
	echo # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
	else
		## turn the cursor back on
		tput civis

		spin &
		SPIN_PID=$!

		trap "kill -9 $SPIN_PID" $(seq 0 15)

		apt install ffmpeg -y

		kill -9 $SPIN_PID

		## turn the cursor back on
		tput cvvis
	fi

fi

if [[ -z "$LAME" ]]; then
	echo "LAME is not installed. Please instal this package to continue"
	echo "exiting...."

	read -p "Would you like to download LAME? " -n 1 -r
	echo # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
	else
		## turn the cursor back on
		tput civis

		spin &
		SPIN_PID=$!

		trap "kill -9 $SPIN_PID" $(seq 0 15)

		apt install libmp3lame0 -y

		kill -9 $SPIN_PID

		## turn the cursor back on
		tput cvvis
	fi
fi

##check if output music folder for mp3 exist and create or empty it
MUSIC_OUTPUT_DIR='musicOutput'
CURRENT_DIR='pwd'

if [ ! -d "$MUSIC_OUTPUT_DIR" ]; then
	echo "Music output folder does not exist"
	echo "Creating folder..."

	mkdir "musicOutput"
else
	echo "Opps there is a folder named musicOutput"

	## Prompt to ask user for response before deleting
	echo "About to Delete all files inside musicOutput Directory"
	read -p "Are you sure you a have back up? " -n 1 -r
	echo # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
	else
		cd "$MUSIC_OUTPUT_DIR"
		rm -r *
		echo "Done deleted everything"
		cd ../
	fi

fi

##start the process of conversion
## create a function to store spinner/proggres animation
spin() {
	spinner="/|\\-/|\\-"
	while :; do
		for i in $(seq 0 7); do
			echo -n "${spinner:$i:1}"
			echo -en "\010"
			sleep 1
		done
	done
}

## turn the cursor off
tput civis

## start the spinner after all checks are successfull
## Start the Spinner:
spin &
## Make a note of its Process ID (PID):
SPIN_PID=$!
## Kill the spinner on any signal, including our own exit.
trap "kill -9 $SPIN_PID" $(seq 0 15)

## run the script to convert the audio
## using xargs to create the arguements on the fly
## and output the results to output DIR
find . -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" | xargs -d "\n" -I {} ffmpeg -hide_banner -loglevel error -i {} -b:a 320K -vn "$MUSIC_OUTPUT_DIR"/{}.mp3

cd "$MUSIC_OUTPUT_DIR"
## rename all the newly created files to remove redundant .mp4 naming
for music_mp3_file in *; do
	mv "$music_mp3_file" "$(echo $music_mp3_file | sed "s/.mp4//g;s/.mkv//g;s/.webm//g")"
done

echo "Finished Succesfully"

## turn the cursor back on
tput cvvis

exit 0
