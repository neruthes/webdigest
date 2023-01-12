#!/bin/bash

source .env
source .localenv




### Cover Pic
json_file=$DATADIR/coverpic/random.json
raw_url=$(jq -r .urls.raw $json_file)
item_url=$(jq -r .links.html $json_file)
author_name=$(jq -r .user.name $json_file)
[[ $DOWNLOAD == y ]] && curl "$raw_url" > $DATADIR/coverpic/raw.jpg
img_min_dim="$(identify -format "%[fx:min(w,h)]" $DATADIR/coverpic/raw.jpg)"
img_width="$(identify -format "%[fx:w]" $DATADIR/coverpic/raw.jpg)"
img_height="$(identify -format "%[fx:h]" $DATADIR/coverpic/raw.jpg)"
offset_h=$(( (img_width-img_min_dim)/2 ))
offset_v=$(( (img_height-img_min_dim)/2 ))
echo "offset_h=$offset_h"
echo "offset_v=$offset_v"
convert $DATADIR/coverpic/raw.jpg -crop ${img_min_dim}x${img_min_dim}+$offset_h+$offset_v $DATADIR/final/coverpic.jpg
convert $DATADIR/final/coverpic.jpg -resize 2000x $DATADIR/final/coverpic-prod.jpg
echo "\\coverpic{$item_url}{$author_name}" > $DATADIR/final/coverpic.tex
