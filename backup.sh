#!/bin/bash
#
date=$(date +%Y%m%d)
SOURCE=/var/www
DEST=/var/backup-hetzner
LOCAL=/var/backup-local
LISTDIR=`ls $SOURCE`
LISTEX=`cat /root/bin/exclude.txt`
curlftpfs u114772.your-backup.de /var/backup-hetzner/ -o user=user:password,allow_other,umask=0022
cd $SOURCE
nice -n 19 mysqldump -uroot --lock-tables=false --default-character-set=utf8 --all-databases | gzip > $LOCAL/all_db.sql.gz

for i in $LISTDIR;
 do nice -n 19 tar cvzf $LOCAL/$i.tar.gz -X '/root/bin/exclude.txt' $i;
done

for n in $LISTEX;
 do nice -n 19 rm $LOCAL/$n.tar.gz;
done

nice -n 19 tar cvzf $LOCAL/ispmgr5.tar.gz /usr/local/mgr5
nice -n 19 tar cvzf $LOCAL/etc.tar.gz /etc

nice -n 19 cp -rf $LOCAL/* $DEST/

fusermount -u /var/backup-hetzner/

unset LISTDIR
unset LISTEX
