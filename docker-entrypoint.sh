#!/bin/bash

set -e

if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ];then
    for i in `seq 6`
    do
        if [ -f /symfony/web/uploads/start  ];then
            supervisord.sh "$@" &
            echo "supervisord is running"
            while true
            do
                if [ -f /symfony/web/uploads/start ];then
                    echo "gfs is running"
                    sleep 5
                    continue
                else
                    killall supervisord
                    echo "check gfs file error"
                    exit 1
                fi
            done
        else
            if [ $i -eq 6 ];then
                echo "gfs not running status: exit 1"
                exit 1
            fi
            echo "第${i}次等待,超过5次等待将会退出"
            sleep 5
        fi
    done

fi

exec "$@"
