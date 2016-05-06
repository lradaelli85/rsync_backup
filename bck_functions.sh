#!/bin/bash
#Author: Luca Radaelli <lradaelli85@users.noreply.github.com>
##################################################################
. parameters.conf 
###################################################################

mail_report(){
	if	[ $email_report = yes ]
	 then
	  send_email $1
	fi
}
check_space(){
local perc="75"
local perc_used=`df -h |grep $mt_point |awk '{print $5}'|tr -d "%"`
local free_space=$((100 - $perc_used))
local total=`df -h |grep $mt_point |awk '{print $2}'`
#check if there is enough space on disk
if [[ $perc_used < $perc ]]
   then
   echo "[OK]: partion mounted on $mt_point has $free_space"%" of free space">>$logfile
     else
     echo "[WARNING]: space used on partition  mounted on $mt_point is higher than $perc"%" !!!">>$logfile
     err_level="1"
fi
}

check_mount(){
#check if disk is mounted
 if  [ `grep -c $mt_point /proc/mounts` -eq  1 ]
     then
     echo "[OK]: USB disk mounted on " $mt_point>>$logfile
     else 
      echo "[ERROR]: USB disk not mounted on "$mt_point >>$logfile
      err_level="2"
      mail_report $err_level
      exit 1;
 fi
}
check_selections(){
while read line
do
if [ -e $line ] && [ -s $line ] && [ -f $line ] || [ -d $line ]
then
echo "[OK]:"$line" exists" >> $logfile
else
       echo "[ERROR]:"$line"  does not exists." >> $logfile
       err_level="2"
       mail_report $err_level
       exit 1;
fi
done < $selection
}

check_configurations(){
#check if the needed folder are there
  for i in $backup_dir $backup_root $selection $mt_point/backup/weekly $mt_point/backup/monthly
  do
   if [ -e $i ] && [ -s $i ] && [ -f $i ] || [ -d $i ]
    then
       echo "[OK]:"$i"  present" >> $logfile
    else
       echo "[ERROR]:"$i"   not present." >> $logfile
       err_level="2"
       #mail_report $err_level
       #exit 1; 
   fi 
  done
     if [ $err_level -gt 0 ]
       then
       mail_report $err_level
       exit 1; 
      fi  
}


check_param(){
   echo " ">$logfile
   echo " ">>$logfile
   echo "===================================" >>$logfile
   echo "checking script parameters definitions" >>$logfile
   echo " ">>$logfile
   echo "process started at "`date` >>$logfile
   
check_mount
check_space
check_selections
check_configurations
}

check_for_compression_errors()
{
if [ $? -ne 0 ]
  then
   echo "[ERROR]:one or more errors during backup compression" >> $logfile
   err_level="1"
    else
      echo "backup ended at "`date` >>$logfile
fi
}

check_for_rsync_errors()
{
if [ $? -ne 0 ]
 then
  echo "[ERROR]:error during rsync copy of $1 " >> $logfile
   err_level="1"
 else
  echo "[OK]: $1 copied correctly">> $logfile
fi
}

check_folder_creation()
{
if [ $? -ne 0 ]
 then
  echo "[ERROR]:error during backup folder creation" >> $logfile
  err_level="2"
  mail_report $err_level
  exit 1;
 else
  echo "ok" > /dev/null
fi
}

send_email()
{
local Subject="Rsync Backup [OK]"
local Message="[OK]:backup completed correctly"
if [ "$1" -eq 2 ]
then
Message="[ERROR] backup failed,please check the logs"
Subject="Rsync Backup [ERROR]"
$SendEmail -f $From -t $To -u $Subject -m $Message -s $Smtp_relay -a $logfile -o tls=no
elif [ "$1" -eq 1 ]
then
Message="[WARNING] backup completed with errors,please check the logs"
Subject="Rsync Backup [WARNING]"
$SendEmail -f $From -t $To -u $Subject -m $Message -s $Smtp_relay -a $logfile -o tls=no
else
$SendEmail -f $From -t $To -u $Subject -m $Message -s $Smtp_relay -a $logfile -o tls=no
fi
}

do_rsync() {
echo "backup started at "`date` >>$logfile
if [ -e $rsync_log ]
 then 
   rm $rsync_log
fi   
touch $rsync_log
if [ ! -z $2 ] && [ $2 = "daily" ]
then
incremental="--backup-dir=$backup_root$1"
elif [ ! -z $2 ] && [ $2 = "weekly" ]
then
incremental="--backup-dir=$backup_root"weekly"/$1"
else
incremental="--backup-dir=$backup_root"monthly"/$1"
fi
while read line
do
rsync $rsync_param $incremental $line $backup_dir >>$rsync_log 
check_for_rsync_errors $line
#rsync -avzR -e "ssh -i /root/.ssh/id_rsa" root@host.local:/path/of/host.local $backup_dir
#check_for_rsync_error
done < $selection
}

do_backup()
{
do_rsync $1	$2
if [ ! -z $2 ] && [ $2 = "Monthly" ]
then
rm -f $backup_root"monthly"/$1/backup-$1.tar.gz
echo "starting backup compression">>$logfile
tar -pzcf $backup_root"monthly"/$1/backup-$1.tar.gz $backup_dir > /dev/null
check_for_compression_errors
mail_report $err_level
fi
}
