
#!/bin/bash
# A script that will backup files and then compress it. Has an option to do non compressed backups and also do a restore of archives.
#NOTE: Doesnt work with directories yet!
# Kevin Mostert
# 25/03/2019

#Test to make sure that arguments are entered.
TYPETEST="$1""$2""$3"
if [ ! -n "$TYPETEST" ]
then
	echo 'Please specify at least one file or directory to backup.'
	exit 1
fi

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

#BACKINGUP
# For each $1....$n, do
for i in "$@"
do

	base_file1=$(basename "$i" .gz)		#The base file without extensions
	base_file2=$(basename "$base_file1" .bck)
	location=$(pwd "$i")			#Path to file

	#Non-compression Archiving
	if [[ $has_n_option = true && $has_r_option = false ]]
	then
		echo "Non-compression backup of "$i" started."
		#File exists and string is non-zero and doesnt have a .bck* extension
		if [ -e "$i" ] && [ ! -z "$i" ] && [[ $i != *.bck* ]]
		then
			cp -i "$i" "$i".bck
			echo "NON-COMPRESSED - Archive of "$i" in "$location" completed on $(date)" | tee -a /home/kevin/scripts.log
		#File doesn't exist and the string is non-zero
		elif [ ! -e "$i" ] && [ ! -z "$i" ]
		then
			echo ""$i" does not exist. It wasnt backed up!"
		#File already has a .bck* extension
		elif [ -e "$i" ] && [ ! -z "$i" ] && [[ $i = *.bck* ]]
		then
			echo "Please choose the base file, "$base_file2" , to archive, "$i" seems to already be a backup."
		else
			echo ""$i" wasn't backed up!, something went wrong!"
		fi
	fi

	# Compression Archiving
	if [[ $has_n_option == false ]] && [[ $has_r_option == false ]]
	then
		echo "Compression backup of "$i" started."
		# If file* exists and string is not zero and the file isnt a backup and there is no *.bck* in directory already
		if [[ -e $i ]] && [[ ! -z $i ]] && [[ $i != *.bck* ]] && [[ ! -e $i.bck.gz ]] && [[ ! -e $i.bck ]]
		then
			echo "A"
			cp "$i" "$i".bck
			gzip "$i".bck
			echo "COMPRESSED - Archive of "$i" in "$location" completed on $(date)" | tee -a /home/kevin/scripts.log
			gzip -l "$i".bck.gz >> /home/kevin/scripts.log

		# If file* exists and string is not zero and file.bck* already exist
		elif [[ -e $i ]] && [[ ! -z $i ]] && [[ -e $1.bck || -e $1.bck.gz ]]
		then
			echo "B"
#			if [[ -e $i.bck ]]
#			then
#				read -r -p "Since you are compressing "$i", do you want to remove "$i".bck [Y/N]? " response
#				if [[ response =~ [yY(es)* ]]
#				then
#					rm "$i".bck
#					echo ""$1".bck was removed"
#				else
#					echo ""$i".bck was preserved."
#				fi
#			fi
#			cp "$i" "$i".bckz
#			gzip "$i".bckz
#			mv "$i".bckz.gz "$i".bck.gz
#			echo "COMPRESSED - Archive of "$i" completed on $(date)" | tee -a /home/kevin/scripts.log
#			gzip -l "$i".bck.gz >> /home/kevin/scripts.log

		# If file* doesnt exists and string is not zero
		elif [ ! -e "$i" ] && [ ! -z "$i" ]
		then
			echo ""$i" doesn't exist. It wasnt backed up!"
		# IF the compressed arhive aleady exists and is choosen to archive
		elif [ -e $i ] && [ ! -z $i ] && [[ $i = *.bck* ]]
		then
			echo "Please choose the base file to archive, "$i" seems to already be a backup."

		else
			echo ""$i" wasn't backed up!, something went wrong!"
		fi
	fi
done

#RESTORING
for i in "$@"
do
	if [[ $has_r_option = true ]] && [[ $has_n_option = false ]]
	then
		echo "Un-Archiving $i"
		if [[ -e $i ]] && [[ "$i" = *.bck ]]
		then
			echo "Resoring Non-Compressed File - "$i""
			base=$(basename "$i" .bck)
			location=$(pwd "$i")
			mv "$i" "$location"/"$base"
			echo "Un-Archive of "$i" to "$location/" , completed on $(date)" | tee -a /home/kevin/scripts.log
		elif [[ -e $i ]] && [[ "$i" = *.bck.gz ]]
		then
			echo ""$i" - Compressed File"
			gzip -d "$i"
			base=$(basename "$i" .bck.gz)
			location=$(pwd "$i")
			mv $(basename "$i" .gz) "$location"/"$base"
			echo "Un-Archive of "$i" to "$location"/"$base" , completed on $(date)" | tee -a /home/kevin/scripts.log
		elif [[ -e $i ]] && [[ "$i" != *.bck || "$i" != *.bck.gz ]]
		then
			echo ""$i" doesnt seem to be a supported file!"
		elif [[ ! -e $i ]]
		then
			echo ""$i" doesn't exist. It wasn't restored!"
		else
			echo ""$i" wans't restored, something went wrong!"
		fi
	fi
done


###	TESTING AREA ##########
echo "Validators"
echo '#################################'
#if [[ $1 == *bck ]]
#then
#	echo ""
#	echo "$1 is a backup file with $base as base"
#elif [[ $1 != *.bck ]]
#then
#	echo ""
#	echo "$1 is NOT a backup file"
#fi

#echo ""
#echo "Base1:$base_file1"
#echo "Base2:$base_file2"
#echo "$location/$base"
echo "Filei: "$i""
#echo "File1: $1"
#echo "File2: $2"
#echo "File3: $3"
#echo "R: $has_r_option"
#echo "N: $has_n_option"

exit 0
