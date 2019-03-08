# rsync_backup

rsync backup bash script

# INSTALLATION

run the script install.sh,in order to copy the binary and the configuration files in the correct folders.

If you do not want to use the default locations,please change the parameters in parameters.conf file.

To have the scheduled jobs you should create 3 differents cron:

### -daily [from monday to friday]

00 22	* * *	root	test -x /usr/local/bin/daily || /usr/local/bin/daily

### -weekly [every saturday]

00 22	* * 6   root    test -x /usr/local/bin/weekly || /usr/local/bin/weekly

### -monthly [first sunday of the Month]

00 22   * * 0   root    if [ -x /usr/local/bin/monthly ] && [ $(date +\%d) -le 7 ];then /usr/local/bin/monthly; fi
