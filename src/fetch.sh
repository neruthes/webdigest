#!/bin/bash

source .env
source .localenv



mkdir -p $DATADIR/{coverpic,final}

SOURCES_LIST="hackernews v2ex solidot zaobao dribbble github ap"
for i in $SOURCES_LIST; do
    mkdir -p $DATADIR/$i
done


if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


case $1 in
    coverpic)
        json_file=$DATADIR/coverpic/random.json
        curl https://api.unsplash.com/photos/random?client_id=$UNSPLASH_API_KEY > $json_file
        raw_url=$(jq -r .urls.raw $json_file)
        item_url=$(jq -r .links.html $json_file)
        author_name=$(jq -r .user.name $json_file)
        ;;
    hackernews)
        curl https://hnrss.org/newest.jsonfeed?points=100 > $DATADIR/hackernews/newest.json
        ;;
    v2ex)
        curl 'https://www.v2ex.com/index.xml' > $DATADIR/v2ex/index.xml
        ;;
    solidot)
        curl 'https://rsshub.app/solidot/linux' > $DATADIR/solidot/solidot.xml
        ;;
    zaobao)
        curl 'https://rsshub.app/zaobao/znews/china' > $DATADIR/zaobao/zaobao.xml
        ;;
    dribbble)
        curl 'https://rsshub.app/dribbble/popular/week' > $DATADIR/dribbble/dribbble.xml
        ;;
    github)
        curl 'https://rsshub.app/github/trending/daily/any/any' > $DATADIR/github/github.xml
        ;;
    ap)
        curl 'https://rsshub.app/apnews/topics/ap-top-news' > $DATADIR/ap/ap.xml
        ;;
    '')
        bash $0 coverpic
        bash $0 $SOURCES_LIST
        ;;
esac
