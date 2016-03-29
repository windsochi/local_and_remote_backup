```sh
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
```

Скрипт помещается в crontab

В скрипте используется утилита curlftpfs, которую необходимо установить перед началом выполнения скрипта


##### Описание скрипта
#
установка интерпретатора
```sh
#!/bin/bash
```
установка в переменнную date текущей даты
```sh
date=$(date +%Y%m%d)
```
установка в переменную SOURCE источника архивирования, то есть что архивируется
```sh
SOURCE=/var/www
```
установка в переменную DEST директорию назначения архивирования, то есть куда архивируется. В переменной указывается адрес точки монтирования для удалённого FTP
```sh
DEST=/var/backup-hetzner
```
установка в переменную LOCAL директории для хранения локальной копии
```sh
LOCAL=/var/backup-local
```
в переменной LISTDIR выполняется команда, в которой происходит вывод списка директорий для архивирования
```sh
LISTDIR=`ls $SOURCE`
```
в переменную LISTEX устанавливается список директорий, которые подлежать исключению из списка директорий на резервную копию
```sh
LISTEX=`cat /root/bin/exclude.txt`
```
с помощью этой команды происходит монтирование удаленного FTP-сервера в директорию /var/backup-hetzner/
```sh
curlftpfs u114772.your-backup.de /var/backup-hetzner/ -o user=user:password,allow_other,umask=0022
```
переходим в директорию, в которой хранятся сайты
```sh
cd $SOURCE
```
с пониженным приоритетом выполняется дамп всех баз данных
```sh
nice -n 19 mysqldump -uroot --lock-tables=false --default-character-set=utf8 --all-databases | gzip > $LOCAL/all_db.sql.gz
for i in $LISTDIR;
do nice -n 19 tar cvzf $LOCAL/$i.tar.gz -X '/root/bin/exclude.txt' $i;
done
```
в цикле перебираются директории, которые подлежать архивированию, каждая из которых с пониженным приоритетом сжимается архиватором tar. В цикле удаляются архивы, которые не требуется сохранять
```sh
for n in $LISTEX;
 do nice -n 19 rm $LOCAL/$n.tar.gz;
done
```
с пониженным приоритетом выполняется архивирование ISPmanager 5 версии
```sh
nice -n 19 tar cvzf $LOCAL/ispmgr5.tar.gz /usr/local/mgr5
```
с пониженным приоритетом выполняется архивирование директории /etc
```sh
nice -n 19 tar cvzf $LOCAL/etc.tar.gz /etc
```
выполняется отключение удаленного FTP-сервера
```sh
fusermount -u /var/backup-hetzner/
```
выполняется удаление переменной со списком директорий
```sh
unset LISTDIR
```
выполняется удаление переменной со списком директорий, которые подлежат исключению из 
резервных копий
```sh
unset LISTEX
```
