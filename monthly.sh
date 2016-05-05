#!/bin/bash
. parameters.conf 
. bck_functions.sh
check_param

#if [ $DAY_week = "dom" ] || [ $DAY_week = "sun" ] && [ $DAY_num -le 7 ] 
#  then
      if [ -e $backup_root"monthly"/$Month ]
        then
          do_backup $Month Monthly
          exit $?;
        else
          mkdir $backup_root"monthly"/$Month 2>/dev/null
          check_folder_creation
          do_backup $Month Monthly          
          exit $?;
        fi
#elif [ $DAY_week = "dom" ] || [ $DAY_week = "sun" ] && [ $DAY_num -gt 7 ]
#     then
#       echo "not first Sunday of the Month" >> $logfile
#       exit 0;
#fi  
