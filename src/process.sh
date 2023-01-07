#!/bin/bash

source .env
source .localenv


### Cover Pic
json_file=webdb/$DATEMARK/coverpic/random.json
raw_url=$(jq -r .urls.raw $json_file)
item_url=$(jq -r .links.html $json_file)
author_name=$(jq -r .user.name $json_file)
[[ $DOWNLOAD == y ]] && curl "$raw_url" > webdb/$DATEMARK/coverpic/raw.jpg
img_min_dim="$(identify -format "%[fx:min(w,h)]" webdb/$DATEMARK/coverpic/raw.jpg)"
img_width="$(identify -format "%[fx:w]" webdb/$DATEMARK/coverpic/raw.jpg)"
img_height="$(identify -format "%[fx:h]" webdb/$DATEMARK/coverpic/raw.jpg)"
offset_h=$(( (img_width-img_min_dim)/2 ))
offset_v=$(( (img_height-img_min_dim)/2 ))
echo "offset_h=$offset_h"
echo "offset_v=$offset_v"
convert webdb/$DATEMARK/coverpic/raw.jpg -crop ${img_min_dim}x${img_min_dim}+$offset_h+$offset_v webdb/$DATEMARK/final/coverpic.jpg
convert webdb/$DATEMARK/final/coverpic.jpg -resize 2000x webdb/$DATEMARK/final/coverpic-prod.jpg
echo "\\coverpic{$item_url}{$author_name}" > webdb/$DATEMARK/final/coverpic.tex



### Genric sources
node src/processors/hackernews.js
node src/processors/v2ex.js
