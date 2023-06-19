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
# if [[ $(id -u) -ne 0 ]]; then
# 	echo "You need Super User priviledges to run this script"
# 	exit 1
# fi

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

##check if both LAME and FFMPEG is installed
if ! (which lame &>/dev/null && which ffmpeg &>/dev/null); then
    echo "Either lame or ffmpeg (or both) are not installed."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

##check if output music folder for mp3 exist and create or empty it
MUSIC_OUTPUT_DIR='musicOutput'
CURRENT_DIR='pwd'
UNPROCESSED_MUSIC='unprocessedMusic'

if [ ! -d "$MUSIC_OUTPUT_DIR" ]; then
	echo "Music output folder does not exist"
	echo "Creating folder..."

	mkdir "musicOutput"
else
	echo "Opps there is a folder named musicOutput. Do you want to Delete all files inside the Directory"

	## Prompt to ask user for response before deleting
	read -p "Are you sure you a have back up? " -n 1 -r
	echo # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
	else

		cd "$MUSIC_OUTPUT_DIR"

		if [ "$(ls -A)" ]; then
			# Delete all the items within the folder
			rm -r ./*
			echo "Done deleting Music Output Dir Files"
			cd ../
		else

			cd ../

		fi

	fi

fi

##start the process of conversion

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
find "$UNPROCESSED_MUSIC" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) -print0 | xargs -0 -I {} sh -c 'ffmpeg -hide_banner -loglevel error -i "$1" -q:a 0 -vn -c:a libmp3lame -b:a 320k "$2/$(basename "$1").mp3"' _ {} "$MUSIC_OUTPUT_DIR"

cd "$MUSIC_OUTPUT_DIR"

## rename all the newly created files to remove redundant .mp4 naming
if [ "$(ls -A)" ]; then
	# Delete all the items within the folder
	for music_mp3_file in *; do
		mv "$music_mp3_file" "$(echo "$music_mp3_file" | sed "s/.mp4//g;s/.mkv//g;s/.webm//g")"
	done

	echo "Finished Succesfully"
else

	echo "The Music Output DIR is empty. Something went wrong converting the music"

fi

## turn the cursor back on
tput cvvis

exit 0
