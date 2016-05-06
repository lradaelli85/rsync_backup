#!/bin/bash
. parameters.conf 
. bck_functions.sh
check_param

     if [ -e $backup_root$DAY ]
       then
         do_backup $DAY daily
         exit $?;
         else
         mkdir $backup_root$DAY 2>/dev/null
         check_folder_creation
         do_backup $DAY daily
         exit $?;
     fi
