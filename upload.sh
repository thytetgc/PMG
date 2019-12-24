#!/bin/bash
HOSTL="`hostname`"
HOST='SERVER_FTP'
USER='xxx'
PASS='xxx'
TARGETFOLDER='/Backup/'$HOSTL''
SOURCEFOLDER='/backup'

lftp -e "
open $HOST
user $USER $PASS
lcd
mkdir Backup/'$HOSTL'
lcd $SOURCEFOLDER
mirror --reverse --delete --use-cache --verbose $SOURCEFOLDER $TARGETFOLDER
bye
"
