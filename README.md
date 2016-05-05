# rsync_backup
rsync backup bash script 

In order to let this scripts run correctly you should create 3 differents cron

#daily [from monday to friday]
00 22	* * *	root	test -x /usr/local/bin/daily.sh || /usr/local/bin/daily.sh
#weekly [every saturday]
00 22	* * 6   root    test -x /usr/local/bin/weekly.sh || /usr/local/bin/weekly.sh
#monthly [first sunday of the Month]
00 22   * * 0   root    if [ -x /usr/local/bin/monthly.sh ] && [ $(date +\%d) -le 7 ];then /usr/local/bin/monthly.sh; fi


