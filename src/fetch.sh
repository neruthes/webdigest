#!/bin/bash

source .env
source .localenv



mkdir -p webdb/$DATEMARK/{coverpic,final}

SOURCES_LIST="hackernews v2ex solidot zaobao dribbble"
for i in $SOURCES_LIST; do
    mkdir -p webdb/$DATEMARK/$i
done


if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


case $1 in
    coverpic)
        json_file=webdb/$DATEMARK/coverpic/random.json
        curl https://api.unsplash.com/photos/random?client_id=$UNSPLASH_API_KEY > $json_file
        raw_url=$(jq -r .urls.raw $json_file)
        item_url=$(jq -r .links.html $json_file)
        author_name=$(jq -r .user.name $json_file)
        ;;
    hackernews)
        curl https://hnrss.org/newest.jsonfeed?points=100 > webdb/$DATEMARK/hackernews/newest.json
        ;;
    v2ex)
        curl 'https://www.v2ex.com/index.xml' > webdb/$DATEMARK/v2ex/index.xml
        ;;
    solidot)
        curl 'https://rsshub.app/solidot/linux' > webdb/$DATEMARK/solidot/solidot.xml
        ;;
    zaobao)
        curl 'https://rsshub.app/zaobao/znews/china' > webdb/$DATEMARK/zaobao/zaobao.xml
        ;;
    dribbble)
        curl 'https://rsshub.app/dribbble/popular/week' > webdb/$DATEMARK/dribbble/dribbble.xml
        ;;
    '')
        bash $0 coverpic
        bash $0 $SOURCES_LIST
        ;;
esac
