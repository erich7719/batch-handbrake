#!/bin/bash


#trap ctrl-c and call ctrl_c()
#only usable if run directly
trap ctrl_c INT


######################
#Notes during editing#
######################
#
##shellcheck - to check that the script is correctly written
#
##handbrake_stdout - a file to track transcode progress <--in temp dir for status program to be written later
##pv_stderr - a file to track cp progress must use option -f to force the output <--in temp dir for status program to be written later
#
##pv -fpterb (source) 1> (dest) 2>>dir/pv_stderr <--use in place of cp


###################
#Required programs#
###################
#HandBrakeCLI
#pv


#variables
#edit respective to your directories
logdir='/media/Original/'			#where log files will reside
origdir='/media/Original/Movies/'	#where the original files reside - in may case this is a nfs shares
procdir='/media/Processed/'			#where the final files will reside - in may case this is a nfs shares
localorig='/media/edit/orig/'		#local directory where the original will tempraraly reside
localedit='/media/edit/process/'	#local directory where handbrake will output the processed file
hbset='/media/Original/mine.plist'	#handbrake profile location
hbname='mine'						#name of the profile to use
tempdir='/dev/shm/'					#temporary directory


ctrl_c() {
	PID=$(ps -ef | grep HandBrakeCLI | grep -v grep | awk '{print $2}')
	if [[ "" !=  "$PID" ]]; then
		echo "killing $PID"
		kill -9 "$PID"
	fi
	
	{
	rm -f "$logdir"$((i+1))_of_"${total}" "$localedit"* "$localorig"*
	mv "$logdir"running "$logdir"done
	} >>"$logdir"movie_transcode_log.txt 2>>"$logdir"movie_transcode_error_log.txt
	
	exit 1
}


timestamp() {
	#formatdate structure
	datetime=$(date +%Y-%m-%d-%H-%M-%S)
 
	#Add formatted date and time to the beginning of the error measage
	while read -r line
	do
		echo "$datetime - $line" >>"$logdir"movie_transcode_error.txt
	done
}


trancodefile() {

searchdir=${origdir%?}

	#remove the files from privous transcoding and indicate current transcoding is running
	mv "$logdir"start "$logdir"running
	if [ -f "$logdir"handbrake_log.txt ]; then
		rm "$logdir"handbrake_log.txt
	fi
	if [ -f "&logdir"handbrake_error_log.txt ]; then
		rm "$logdir"handbrake_error_log.txt
	fi
	
	#Get a list of folders to process
	folder=("$origdir"*)
	#total number of folders
	total=$(find "$searchdir" -name '*.mkv' | wc -l)
	
	#set i for the folder ideration
	i=0

	touch "$logdir"$((i+1))_of_"$total" >>"$logdir"movie_transcode_log.txt 2>>"$logdir"movie_transcode_error_log.txt
	
	#traverse the folder structure
	for f in "${folder[@]}"; do
		for file in "$f"/*; do

			#increment i
			i=$(( i + 1 ))

			#Traverse each file for processing
			#seporate the needed names and parts
			filename="$(basename "$file")"
			dirname="$(dirname "$file")"
			dirname="$(basename "$dirname")"
			
			#copy the original filr to a temporary directory for processing
			#add -f and uncomment 2>> after testing
			pv -pterb "$file" 1> "$localorig""$filename" #2>>dir/pv_stderr
			
			#handbrake code to encode the files
			HandBrakeCLI --preset-import-file "$hbset" -Z "$hbname" -i "$localorig""$filename" -o "$localedit""$filename" >>"$logdir"handbrake_log.txt 2>>"$logdir"handbrake_error_log.txt

			#check if the movie title folder exists in the processed directory
			if [ ! -d "$procdir""$dirname" ]; then
				mkdir "$procdir""$dirname" >>"$logdir"movie_transcode_log.txt 2>>"$logdir"movie_transcode_error_log.txt
			fi

			#if the folder has to be made code throws an error is sleep is not here
			sleep 1

			#move the newly created file to the processed directory
			touch "$procdir""$dirname"/"$filename" >>"$logdir"movie_transcode_log.txt 2>>"$logdir"movie_transcode_error_log.txt
			sleep .5
			#add -f and uncomment 2>> after testing
			pv -pterb "$localedit""$filename" 1> "$procdir""$dirname"/"$filename" #2>>dir/pv_stderr
			
			#Format log entery for currently processed files
			currentDate=$(date +%y%m%d%H%M%S)
			echo -e "$currentDate\t${i}_of_${total}\tFolder - $dirname\tFile name - $filename" >>"$logdir"Processed.txt
			
			#Cleanup original and processed files
			{
			rm "$localorig""$filename"
			rm "$localedit""$filename"
			#increment to indicate the next folder
			mv "$logdir"${i}_of_"${total}" "$logdir"$((i+1))_of_"${total}"
			} >>"$logdir"movie_transcode_log.txt 2>>"$logdir"movie_transcode_error_log.txt

   		done
	done

	#Leave behind a file to indicate the process is done
	{
	rm -f "$logdir"$((i+1))_of_"${total}"
	mv "$logdir"running "$logdir"done
	} >>"$logdir"movie_transcode_log.txt 2>>"$logdir"movie_transcode_error_log.txt
}


###############
###Main code###
###############


#check if bash script is already running
if [ -f "$logdir"running ]; then
	echo "bash already running, will shutdown"
	exit 1
fi


#check if start exists
if [ -f "$logdir"start ]; then
	trancodefile
fi
