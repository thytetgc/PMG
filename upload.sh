#!/bin/bash
HOSTL="`hostname`"
HOST='st1.hostlp.cloud'
USER='HostLP'
PASS='admin@hostlp*h05t1p'
TARGETFOLDER='/home/storage/HostLP/Backup/'$HOSTL''
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
