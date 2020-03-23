# Safe USB Backup for Mac

This is a simple backup tool for MacOS.

1. You set a list of folders to backup
2. You set a name of USB drive
3. Every time when this USB drive is inserted the tool will ask you for password to protect your backup, make archive with these folders, encrypt this archive with AESCrypt, put this file on USB and unmount it when done.

## Instructions:

1. Git clone or download this repo
2. [Download](https://www.aescrypt.com/download/) and install AESCrypt if you don't have it yet
3. Put folders you want to backup into in the file `folder.list.example` and rename it to `folder.list`
4. Edit file `com.custom.safebackup_usb.plist.example` and rename it to `com.custom.safebackup_usb.plist`:

- Put path to current start_backup_usb.sh (line 10)
- Put name of your USB which will be used for automatic backup (line 11)
- Put path to folder with `folders.list` file (line 12)

5. Run install_daemon script: `sudo sh install_daemon.sh`

Now after inserting USB drive with according name you will be prompted to enter password for backup encryption. USB will be automatically unmounted when backup proccess finished.

First time when script is triggered you will be prompted to grant access for notification and dialog windows. You should allow this access. Every time when backup started old backup files will be deleted.
