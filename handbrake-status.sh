#!/bin/bash

trap ctrl_c int

#check if runhandbrake is running or not

#if runhandbrake is running check which files are present in the temp dir; if not state no transcoding is going on.


#file list
#handbrake_stdout
#pv_sterr
#need a file to record "what direction a transfer is going", "title of the current file", "file count"


#put variables into a file as comma delimited, we'll call this file "history.txt"
#read last lines using "tag=$( tail -n 1 history.txt )"
#we will call the new array "datarray"
#readarray -td, datarray <<<"$string,"; unset 'datarray[-1]'; declare -p datarray;


#function for if file is being moved to tempdir

#function for if a transcode is going on

#function for if file is being moved back from tempdir


