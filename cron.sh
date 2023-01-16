#!/bin/bash

### This script may be used as the entry for a cronjob
# 00 0 * * * bash /home/neruthes/DEV/webdigest/cron.sh
# Run this job at 00:00 UTC

source /home/neruthes/.bashrc
s5pon h

cd /home/neruthes/DEV/webdigest

bash build.sh today > .tmp/buildlog.txt 2>&1

WRITE_OSSLIST=n minoss _dist/tgmsg.txt



echo -e "*Build job completed at $(date '+%F %T')*\n" > .tmp/notif.txt

if grep -qsi error .tmp/buildlog.txt; then
    echo -e "Found some error in the build log." >> .tmp/notif.txt
else
    echo -e "Everything looks good.\n" >> .tmp/notif.txt
fi
minoss .tmp/buildlog.txt | grep '^FINAL_HTTP_URL=' | cut -d= -f2 >> .tmp/notif.txt 2>/dev/null

echo -e '\n''TgMsg is ready:

https://minio-zt.neruthes.xyz/oss/keep/webdigest/tgmsg.txt--66cefd096d8849b060a4b71eeba91963.txt' >> .tmp/notif.txt

tgbot-msg /home/neruthes/DEV/clinotifbot-tg $(pasm p tgid) < .tmp/notif.txt



### And play with experimental ApubNode instance
cd /home/neruthes/DEV/mypubnode
apubnode newnote webdigest '' <<< /home/neruthes/DEV/webdigest/_dist/tgmsg.html
# bash build.sh cf
# git add .
# git commit -m 'Automatic commit '"$(date '+%F %T')"
# git push
