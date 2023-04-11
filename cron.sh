#!/bin/bash

### This script may be used as the entry for a cronjob
# 01 0 * * * bash /home/neruthes/DEV/webdigest/cron.sh
# Run this job at 00:00 UTC




### Prepare environment
source /home/neruthes/.bashrc
s5pon h
cd /home/neruthes/DEV/webdigest


### Delete existing boom alert
BOOMALERT=".tmp/autobuild_disaster.txt"
[[ -e $BOOMALERT ]] && rm $BOOMALERT


### Start building artifacts
bash build.sh today > .tmp/buildlog.txt 2>&1


### Upload build log
WRITE_OSSLIST=n minoss .tmp/buildlog.txt


### Generate Telegram bot message
echo -e "<strong>Build job completed at $(date '+%F %T')</strong>" > .tmp/notif.html
if grep -qsi error .tmp/buildlog.txt; then
    echo -e "Found some error in the build log." >> .tmp/notif.html
else
    echo -e "Everything looks good." >> .tmp/notif.html
fi
echo -e "<a href='https://minio.neruthes.xyz/oss/keep/webdigest/buildlog.txt--a43ccfb78e5b960ad7a2b6226572bf19.txt'>
https://minio.neruthes.xyz/oss/keep/webdigest/buildlog.txt--a43ccfb78e5b960ad7a2b6226572bf19.txt
</a>" >> .tmp/notif.html 2>/dev/null

pdfurl="https://nas-public.neruthes.xyz/webdigest-07f285cda0d2dd34bc7a4d07/$(find _dist/issue -name '*.pdf' | sort -r | head -n1)"
echo -e "Artifact:
<a href='$pdfurl'>$pdfurl</a>" >> .tmp/notif.html


### Synchronize to NAS public
shareDirToNasPublic


### Send Telegram bot message
MARKUP=HTML tgbot-msg /home/neruthes/DEV/clinotifbot-tg $(pasm p tgid) .tmp/notif.html
MARKUP=HTML tgbot-msg /home/neruthes/DEV/clinotifbot-tg $(pasm p tgid) _dist/tgmsg.txt
[[ -e $BOOMALERT ]] && MARKUP=HTML tgbot-msg /home/neruthes/DEV/clinotifbot-tg $(pasm p tgid) <(echo -e "<strong>----- BOOM ALERT -----</strong>\n\n"; cat $BOOMALERT)


### And play with experimental ApubNode instance
cd /home/neruthes/DEV/mypubnode
apubnode newnote webdigest '' < /home/neruthes/DEV/webdigest/_dist/tgmsg.html
bash build.sh deploy
git add .
git commit -m 'Automatic commit '"$(date '+%F %T')"
git push
