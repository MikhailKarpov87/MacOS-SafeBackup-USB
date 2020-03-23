#!/bin/bash
USB_NAME=$1
SCRIPT_PATH=$2
AESCRYPT_BIN_PATH=/Applications/AESCrypt.app/Contents/MacOS/aescrypt

function showNotification () {
  osascript -e "tell app \"System Events\" to display notification \"$2\" with title \"$1\""
}

if [ ! -d /Volumes/$USB_NAME ]; then
    exit 0
else
    #Get folders list
    IFS=$'\n' read -d '' -r -a lines < $SCRIPT_PATH/folders.list
    PATHS_TO_SAVE=${lines[*]}

    #Exit if no paths found
    if [ ! ${#lines[@]} ]; then
        exit 1
    fi

    BACKUP_SIZE=$(($(du -csm $PATHS_TO_SAVE | grep total | grep -o '[0-9]\+')+0))
    TOTAL_DISK_FREESPACE=$(($(df -m . | tail -1 | awk '{print $4}' )+0))
    TOTAL_USB_FREESPACE=$(($(df -m /Volumes/$USB_NAME | tail -1 | awk '{print $4}' )+0))


    if [ "$BACKUP_SIZE" -gt "$TOTAL_DISK_FREESPACE" ]; then
        showNotification 'USB SafeBackup' 'Not enought free space for backup! Free '$BACKUP_SIZE'Mb or use another USB'
        exit 0
    fi

    if [ "$BACKUP_SIZE" -gt "$TOTAL_USB_FREESPACE" ]; then
        showNotification 'USB SafeBackup' 'Not enought free space on USB drive for backup! Free '$BACKUP_SIZE'Mb or use another USB'
        exit 0
    fi

    if [ "$BACKUP_SIZE" -lt "$TOTAL_DISK_FREESPACE" -a "$BACKUP_SIZE" -lt "$TOTAL_USB_FREESPACE" ]; then
        SURETY="$(osascript -e 'tell app "Finder" to display dialog "Start Backup (~'$BACKUP_SIZE'Mb) ?" buttons {"No", "Yes"}' )"

        if [ "$SURETY" = "button returned:Yes" ]; then
            #Request password for backup archive
            PASSWORD=`osascript -e 'tell app "Finder" to set T to text returned of (display dialog "Enter password for backup file:" buttons {"Cancel", "OK"} default button "OK" default answer "")'`
            showNotification 'USB SafeBackup' 'Backup started..'
            FILENAME=$(date +'%Y-%m-%d-%H-%M')_backup.zip
            BACKUP_FILENAME=$(date +'%Y-%m-%d-%H-%M').zip.aes
            cd ~/
            zip -r $FILENAME $PATHS_TO_SAVE
            $AESCRYPT_BIN_PATH -e -o $BACKUP_FILENAME -p $PASSWORD $FILENAME
            rm ~/$FILENAME
            find /Volumes/$USB_NAME/ -type f -name '*.zip.aes' -delete
            mv ~/$BACKUP_FILENAME /Volumes/$USB_NAME/$BACKUP_FILENAME
            diskutil unmountDisk $USB_NAME
            showNotification 'USB SafeBackup' 'Backup finished! '$BACKUP_SIZE'Mb was copied to '$USB_NAME''
        fi
    fi
fi
exit 0