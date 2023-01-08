#!/bin/bash

source .env
source .localenv



[[ -e today ]] && rm today
ln -svf webdb/$DATEMARK/final today


mkdir -p issue/${DATEMARK:0:4}

latex_file_path="issue/${DATEMARK:0:4}/WebDigest-$DATEMARK.tex"



### Head
sed "s|DATESTRING|$(date '+%F')|g" .texlib/template-v1.tex | sed "s|FINALDIR|$DATADIR/final|" > $latex_file_path



echo $latex_file_path
