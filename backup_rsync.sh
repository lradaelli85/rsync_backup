#!/bin/bash
# Description:       This script will run a backup uding rsync.
#                    It keeps a copy of backup from Monday to Friday,and every first 
#                    Sunday a Monthly copy is kept also.
#  					 To send the email it requires sendemail
#Author: Luca Radaelli <lradaelli85@users.noreply.github.com>
##################################################################
#inserire qui i parametri
mt_point="/media/luke/bckdsk"
logfile="/home/luke/rsync_backup.log"
rsync_log="/home/luke/`date +"%d%m%Y"`-rsync.log"
backup_dir="$mt_point/backup/test/"
backup_root="$mt_point/backup/"
selection="selections.txt"
DAY=`date +"%A"`
#DAY="saturday"
DAY_week=`date +"%a" |tr '[:upper:]' '[:lower:]'`
#DAY_week="sat"
DAY_num=`date +"%d"`
#DAY_num="22"
Month=`date +"%B"`
err_level="0"
rsync_param="-pazvhrR"
#rsync_param="-npazvhr" 
###################################################################

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

check_param(){
local bool="0"
   echo " ">$logfile
   echo " ">>$logfile
   echo "===================================" >>$logfile
   echo "checking script parameters definitions" >>$logfile
   echo " ">>$logfile
   echo "process started at "`date` >>$logfile
   
#check if disk is mounted
 if  [ `grep -c $mt_point /proc/mounts` -eq  1 ]
     then
     echo "[OK]: USB disk mounted on " $mt_point>>$logfile
     else 
      echo "[ERROR]: USB disk not mounted on "$mt_point >>$logfile
      err_level="2"
      #send_email $err_level
      exit 1;
 fi
 
check_space

#check if the needed folder are there
  for i in $backup_dir $backup_root $selection
  do
   if [ -e $i ] && [ -s $i ] && [ -f $i ] || [ -d $i ]
    then
       echo "[OK]:"$i"  present" >> $logfile
    else
       echo "[ERROR]:"$i"   not present." >> $logfile
       err_level="2"
       bool=1
   fi
  done
  
   if [ $bool -eq "0" ]
    then
     echo
    else
     echo "backup failed,please check the prameters">>$logfile
     err_level="2"
     send_email $err_level
     exit 1;
   fi
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
  send_email $err_level
  exit 1;
 else
  echo "ok" > /dev/null
fi
}

send_email()
{
local SendEmail="/usr/bin/sendemail"
local From="test@test"	
local To="test@test"
local Subject="Rsync Backup [OK]"
local Message="[OK]:backup completed correctly"
local Smtp_relay="10.4.0.128"
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
while read line
do
rsync $rsync_param $line $backup_dir >>$rsync_log 
check_for_rsync_errors $line
#rsync -avzR -e "ssh -i /root/.ssh/id_rsa" root@host.local:/path/of/host.local $backup_dir
#check_for_rsync_error
done < $selection
}

do_backup()
{
do_rsync	
rm -f $backup_root$1/backup-$1.tar.gz
echo "starting backup compression">>$logfile
tar -pzcf $backup_root$1/backup-$1.tar.gz $backup_dir > /dev/null
check_for_compression_errors	
}


check_day() {
#check for monthly backup
if [ $DAY_week = "dom" ] || [ $DAY_week = "sun" ] && [ $DAY_num -le 7 ] 
  then
      if [ -e $backup_root$Month ]
        then
          do_backup $Month
        else
          mkdir $backup_root$Month
          check_folder_creation
          do_backup $Month
        fi
elif [ $DAY_week = "dom" ] || [ $DAY_week = "sun" ] && [ $DAY_num -gt 7 ]
     then
       echo "not first Sunday of the Month" >> $logfile
       exit 0;
fi    
#check for weekly backup   
  if [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -le 7 ] 
      then
        if [ -e $backup_root"week1" ]
          then
            do_backup week1
          else
          mkdir $backup_root$"week1"
          check_folder_creation
          do_backup week1
        fi
   elif [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -gt 7 ] && [ $DAY_num -le 14 ] 
          then
          if [ -e $backup_root"week2" ]
          then
            do_backup week2
          else
          mkdir $backup_root$"week2"
          check_folder_creation
          do_backup week2
       fi
    elif [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -gt 14 ] && [ $DAY_num -le 21 ] 
          then
           if [ -e $backup_root"week3" ]
           then
            do_backup week3
          else
          mkdir $backup_root$"week3"
          check_folder_creation
          do_backup week3
       fi
    elif [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -gt 21 ] && [ $DAY_num -le 28 ] 
          then
          if [ -e $backup_root"week4" ]
          then
            do_backup week4
          else
          mkdir $backup_root$"week4"
          check_folder_creation
          do_backup week4
       fi
  else
#daily backup
     if [ -e $backup_root$DAY ]
       then
         do_backup $DAY
         else
         mkdir $backup_root$DAY
         check_folder_creation
         do_backup $DAY
     fi
fi
}
#main

check_param
check_day
#send_email $err_level
