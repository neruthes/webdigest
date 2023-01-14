#!/bin/bash

### This script may be used as the entry for a cronjob

cd /home/neruthes/DEV/webdigest

source /home/neruthes/.bashrc

bash build.sh today > .tmp/build.log 2>&1



### And play with experimental ApubNode instance
cd /home/neruthes/DEV/mypubnode
apubnode newnote webdigest '' <<< /home/neruthes/DEV/webdigest/_dist/tgmsg.html
