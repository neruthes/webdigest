#!/bin/bash

source .env
source .localenv



[[ -e today ]] && rm today
ln -svf $DATADIR/final today

mkdir -p issue/$THISYEAR

latex_file_path="issue/$THISYEAR/WebDigest-$DATEMARK.tex"

if [[ $THISYEAR == 2023 ]]; then
    COPYRIGHTYEARSRANGE="2023"
else
    COPYRIGHTYEARSRANGE="2023-$THISYEAR"
fi


### Head
sed "s|DATESTRING|$(date '+%F')|g" .texlib/template-v1.tex |
    sed "s|DATEMARK|$DATEMARK|" |
    sed "s|COPYRIGHTYEARSRANGE|$COPYRIGHTYEARSRANGE|" |
    sed "s|DATETHISYEAR|$THISYEAR|" |
    sed "s|FINALDIR|$DATADIR/final|" > "$latex_file_path"
# DATETHISYEAR


echo $latex_file_path



