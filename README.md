# arhiver
A bash script that will quickly backup and compress your files.

A script that will backup files and then compress it. Has an option to do non-compressed backups and also do a restore of archives.

NOTE: Doesnt work with directories yet!

Usage:
I put a soft link to the archiver.sh file in my /home/user/bin folder. You may choose to instead just put archiver.sh in you bin directory directly. I then edit /home/user/.bin_aliases and add:
  
  alias backup='/bin/bash /home/kevin/bin/archive.sh'
  
  to my .bin_aliases.
  
  Now to do a backup in terminal, I just type "backup filename" with the needed flags.
