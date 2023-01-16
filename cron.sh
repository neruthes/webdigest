#!/bin/bash

### This script may be used as the entry for a cronjob
# 00 0 * * * bash /home/neruthes/DEV/webdigest/cron.sh
# Run this job at 00:00 UTC

source /home/neruthes/.bashrc
s5pon h

cd /home/neruthes/DEV/webdigest

bash build.sh today > .tmp/buildlog.txt 2>&1

WRITE_OSSLIST=n minoss _dist/tgmsg.txt



echo -e "<strong>Build job completed at $(date '+%F %T')</strong><br><br>" > .tmp/notif.html

if grep -qsi error .tmp/buildlog.txt; then
    echo -e "Found some error in the build log.<br><br>" >> .tmp/notif.html
else
    echo -e "Everything looks good.<br><br>" >> .tmp/notif.html
fi
echo -e "<a href='https://minio-zt.neruthes.xyz/oss/keep/webdigest/buildlog.txt--a43ccfb78e5b960ad7a2b6226572bf19.txt'>
    https://minio-zt.neruthes.xyz/oss/keep/webdigest/buildlog.txt--a43ccfb78e5b960ad7a2b6226572bf19.txt
</a><br><br>" >> .tmp/notif.html 2>/dev/null

echo -e "TgMsg is ready:<br>
<a href='https://minio-zt.neruthes.xyz/oss/keep/webdigest/tgmsg.txt--66cefd096d8849b060a4b71eeba91963.txt'>
    https://minio-zt.neruthes.xyz/oss/keep/webdigest/tgmsg.txt--66cefd096d8849b060a4b71eeba91963.txt
</a>
<br><br>" >> .tmp/notif.html

pdfurl="https://nas-public.neruthes.xyz:2096/webdigest-07f285cda0d2dd34bc7a4d07/$(find _dist/issue -name '*.pdf' | sort -r | head -n1)"
echo -e "Artifact:<br>
<a href='$pdfurl'>$pdfurl</a>" >> .tmp/notif.html


cp .tmp/notif.html _dist/notif.html

shareDirToNasPublic

MARKUP=HTML tgbot-msg /home/neruthes/DEV/clinotifbot-tg $(pasm p tgid) <<< "Web Digest build job is over.

<a herf='https://nas-public.neruthes.xyz:2096/webdigest-07f285cda0d2dd34bc7a4d07/_dist/notif.html'>https://nas-public.neruthes.xyz:2096/webdigest-07f285cda0d2dd34bc7a4d07/_dist/notif.html</a>"



### And play with experimental ApubNode instance
# cd /home/neruthes/DEV/mypubnode
# apubnode newnote webdigest '' <<< /home/neruthes/DEV/webdigest/_dist/tgmsg.html
# bash build.sh cf
# git add .
# git commit -m 'Automatic commit '"$(date '+%F %T')"
# git push
