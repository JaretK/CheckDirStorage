#!/bin/bash

currDir=$(pwd)
totalSize=0
numFiles=$(ls | wc -l)

#File system block size = 1024 bytes per -k flag in du
BLOCK_SIZE=1024
currentFileNumber=0
totalDirSize=0

underline=`tput smul`
nounderline=`tput rmul`
bold=`tput bold`
normal=`tput sgr0`

echo
echo ${normal}"Checking size of "$currDir" sub-directories("$numFiles")"


convertToHuman(){
	echo "$1" | awk '{ sum=$1 ; hum[1024**3]="Gb";hum[1024**2]="Mb";hum[1024]="Kb"; for (x=1024**3; x>=1024; x/=1024){ if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x];break } }}'
}

for dir in *; do
	#if [[]]; then
	# -d "$dir" returns true if $dir is a directory
	# ! -L "$dir" returns true of $dir is not a symlink

	#get percent complete in ${currentRatio}
	let currentFileNumber+=+1
	currentRatio=$(echo "scale=2;(${currentFileNumber}/${numFiles})" | bc)
	if [[ $currentRatio = "1.00" ]];
	then
		currentRatio="100%"
	else
		currentRatio=${currentRatio:1}"%"
	fi

	echo -n "Checking "
	if[[ -d "$dir" ]];then
		echo -n "D "
	else
		echo -n "F "
	fi
	
	echo -n ${bold}$dir${normal}": "
	echo -n ${bold}"Size = "${normal}

	saveIFS=$IFS
	line=$(IFS=$'\n'; du -sk ${dir})
	IFS=$saveIFS
	subDirSize=$(echo ${line} | awk -F ' ' '{print $1}')
	blockedSize=$(echo ${subDirSize}*${BLOCK_SIZE} | bc)
	let totalDirSize+=blockedSize
	humanReadableSize=$(convertToHuman $blockedSize)

	echo -n ${bold}$humanReadableSize${normal}" "

	echo $currentRatio" complete"
done

echo "Parse of "$currDir" complete. "${bold}"Total size = "$(convertToHuman $totalDirSize)${normal} 
echo
