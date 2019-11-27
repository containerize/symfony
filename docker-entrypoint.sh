#!/bin/sh

set -e

if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ];then
    for i in `seq 6`
    do
        if [ -f /symfony/web/uploads/start  ];then
            echo "gfs is running"
            break
        else
            if [ $i -eq 6 ];then
                echo "gfs not running status: exit 1"
                exit 1
            fi
            echo "第${i}次等待,超过5次等待将会退出"
            sleep 5
        fi
    done
    
    set -- supervisord "$@"
fi

exec "$@"