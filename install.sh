#!/bin/bash
. parameters.conf

if [ `id -u` -ne 0 ]
 then
  echo "you need root permissions"
  exit 1;
  else
     echo "coping binary in folder"
     cp -va ./{daily,weekly,monthly,bck_functions.sh} $BIN_FODLER
     ln -s $CONF_DIR/parameters.conf $BIN_FODLER/parameters.conf
     if [ ! -d $CONF_DIR ]
        then
        echo "$CONF_DIR does not exist,do you want to create it?[y/n]"
        read r
        case $r in
        y)        
        echo "creating configration folder"
        mkdir $CONF_DIR
        echo "coping configuration files in folder"
        cp -va exclude.txt LICENSE README.md selections.txt parameters.conf $CONF_DIR
        ;;
        n)
        exit 0;
        ;;
        *)
        echo "wrong reply,type y or n"
        ;;
        esac
         else
          cp -va exclude.txt LICENSE README.md selections.txt parameters.conf $CONF_DIR
     fi
     
fi
