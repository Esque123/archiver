#!/bin/bash
# A script that will backup files and then compress it. Has an option to do non compressed backups and also do a restore of archives.
#NOTE: Doesn't work with directories yet!
# Kevin Mostert
# 25/03/2019

# Flag options
has_n_option=false
has_r_option=false
while getopts :hnr opt; do
        case $opt in
                h) echo "Backup and compress files, skip compression with -n flag and restore with the -r flag."; exit;;
                n) has_n_option=true ;;
		r) has_r_option=true ;;
		 :) echo "Missing argument for option -$OPTARG"; exit 1;;
                \?) echo "Unknown option -$OPTARG"; exit 1;;
        esac
done

shift $(( OPTIND -1 ))

#Test to make sure that arguments are entered.
TYPETEST="$@"
if [ -z "$TYPETEST" ]
then
	echo 'Please specify at least one file to backup.'
	exit 1
fi

#Test to make sure that the file is writable
for i in "$@"
do
	if [ ! -w "$i" ]
	then
		echo "Write permission is NOT granted on $i, please run as sudo"
		exit 1
	fi
done

#BACKING UP
# For each $1....$n, do
for i in "$@"
do

	base_file1=$(basename "$i" .gz)		#The base file without extensions
	base_file2=$(basename "$base_file1" .bck)
	location=$(pwd "$i")			#Path to file

	#Non-compression Archiving
	if [[ $has_n_option = true && $has_r_option = false ]]
	then
		echo "Non-compression backup of $i started..."
		#File exists and string is non-zero and doesn't have a .bck* extension
		if [ -e "$i" ] && [ -n "$i" ] && [[ $i != *.bck* ]]
		then
			cp -i "$i" "$i".bck
			echo "NON-COMPRESSED - Archive of $i in $location/ completed on $(date)." | tee -a /home/"$(whoami)"/scripts.log
		#File doesn't exist and the string is non-zero
		elif [ ! -e "$i" ] && [ -n "$i" ]
		then
			echo "$i does not exist. It wasn't backed up!"
		#File already has a .bck* extension
		elif [ -e "$i" ] && [ -n "$i" ] && [[ $i = *.bck* ]]
		then
			echo "Please choose the base file, $base_file2 , to archive, $i seems to already be a backup."
		else
			echo "$i wasn't backed up!, something went wrong!"
		fi
	fi

	# Compression Archiving
	if [[ $has_n_option == false ]] && [[ $has_r_option == false ]]
	then
		echo "Compression backup of $i started..."
		# If file exists and string is not zero and the file isn't a backup and there is no *.bck* in directory already
		if [[ -e $i ]] && [[ -n $i ]] && [[ $i != *.bck* ]] && [[ ! -e $i.bck.gz ]] && [[ ! -e $i.bck ]]
		then
			cp "$i" "$i".bck
			gzip "$i".bck
			echo "COMPRESSED - Archive of $i in $location/ completed on $(date)." | tee -a /home/"$(whoami)"/scripts.log
			gzip -l "$i".bck.gz >> /home/"$(whoami)"/scripts.log

		# If file exists and string is not zero and file.bck* already exist
		elif [[ -e $i ]] && [[ -n $i ]] && [[ -e $1.bck || -e $1.bck.gz ]]
		then
			echo "A backup file of $i already exists "
			if [[ -e $i.bck ]]
			then
				read -r -p "Since you are compressing $i, do you want to delete the existing $i.bck file [Y/N]? " response
				if [[ $response =~ [yY(es)*] ]]
				then
					echo "$1.bck was removed."
					cp "$i" "$i".bck
					gzip -f "$i".bck
					echo "COMPRESSED - Archive of $i to $location/ completed on $(date)." | tee -a /home/"$(whoami)"/scripts.log
					gzip -l "$i".bck.gz >> /home/"$(whoami)"/scripts.log
				else
					echo "$i.bck was preserved."
					cp "$i" "$i".bckz
					gzip "$i".bckz
					mv "$i.bckz.gz" "$i.bck.gz"
					echo "COMPRESSED - Archive of $i to $location/ completed on $(date)." | tee -a /home/"$(whoami)"/scripts.log
					gzip -l "$i".bck.gz >> /home/"$(whoami)"/scripts.log
				fi
			fi

		# If file* doesn't exists and string is not zero
		elif [ ! -e "$i" ] && [ -n "$i" ]
		then
			echo "$i doesn't exist. It wasn't backed up!"
		# IF the compressed archive already exists and is chosen to archive
		elif [ -e "$i" ] && [ -n "$i" ] && [[ $i = *.bck* ]]
		then
			echo "Please choose the base file to archive, $i seems to already be a backup."

		else
			echo "$i wasn't backed up!, something went wrong!"
		fi
	fi
done

#RESTORING
for i in "$@"
do
	if [[ $has_r_option = true ]] && [[ $has_n_option = false ]]
	then
		#echo "Un-Archiving $i"
		if [[ -e $i ]] && [[ "$i" = *.bck ]]
		then
			echo "Restoring Non-Compressed File - $i"
			base=$(basename "$i" .bck)
			location=$(pwd "$i")
			mv "$i" "$base"
			echo "Un-Archive of $i to $location/ , completed on $(date)" | tee -a /home/"$(whoami)"/scripts.log
		elif [[ -e $i ]] && [[ "$i" = *.bck.gz ]]
		then
			echo "Restoring Compressed File - $i"
			gzip -df "$i"
			base=$(basename "$i" .bck.gz)
			location=$(pwd "$i")
			mv "$(basename "$i" .gz)" "$location"/"$base"
			echo "Un-Archive of $i to $location/ , completed on $(date)" | tee -a /home/"$(whoami)"/scripts.log
		elif [[ -e $i ]] && [[ "$i" != *.bck || "$i" != *.bck.gz ]]
		then
			echo "$i doesn't seem to be a supported file! Please choose $i.bck or $i.bck.gz"
		elif [[ ! -e $i ]]
		then
			echo "$i doesn't exist. It wasn't restored!"
		else
			echo "$i wasn't restored, something went wrong!"
		fi
	fi
done

###	TESTING AREA ##########

#echo "Validating"
#echo '#################################'

#if [[ $1 == *bck ]]
#then
#	echo ""
#	echo ""$1" is a backup file with "$base" as base"
#elif [[ $1 != *.bck ]]
#then
#	echo ""
#	echo ""$1" is NOT a backup file"
#fi

#echo "Base1:$base_file1"
#echo "Base2:$base_file2"
#echo "$location/$base"
#echo "Filei: "$i""
#echo "File1: $1"
#echo "File2: $2"
#echo "File3: $3"
#echo "R: $has_r_option"
#echo "N: $has_n_option"

exit 0
