#!/bin/bash

### This script may be used as entry for a cronjob

cd /home/neruthes/DEV/webdigest

source /home/neruthes/.bashrc

bash build.sh today
