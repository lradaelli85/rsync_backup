#!/bin/bash
. parameters.conf 
. bck_functions.sh
check_param

 if [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -le 7 ] 
      then
        if [ -e $backup_root"weekly"/"week1" ]
          then
            do_backup week1 weekly
            exit $?;
          else
          mkdir $backup_root"weekly"/"week1" 2>/dev/null
          check_folder_creation
          do_backup week1 weekly
          exit $?;
        fi
   elif [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -gt 7 ] && [ $DAY_num -le 14 ] 
          then
          if [ -e $backup_root"weekly"/"week2" ]
          then
            do_backup week2 weekly
            exit $?;
          else
          mkdir $backup_root"weekly"/"week2" 2>/dev/null
          check_folder_creation
          do_backup week2 weekly
          exit $?;
       fi
    elif [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -gt 14 ] && [ $DAY_num -le 21 ] 
          then
           if [ -e $backup_root"weekly"/"week3" ]
           then
            do_backup week3 weekly
            exit $?;
          else
          mkdir $backup_root"weekly"/"week3" 2>/dev/null
          check_folder_creation
          do_backup week3 weekly
          exit $?;
       fi
    elif [ $DAY_week = "sat" ] || [ $DAY_week = "sab" ] && [ $DAY_num -gt 21 ] && [ $DAY_num -le 28 ] 
          then
          if [ -e $backup_root"weekly"/"week4" ]
          then
            do_backup week4 weekly
            exit $?;
          else
          mkdir $backup_root"weekly"/"week4" 2>/dev/null
          check_folder_creation
          do_backup week4 weekly
          exit $?;
       fi
 fi
