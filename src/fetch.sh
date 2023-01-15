#!/bin/bash

source .env
source .localenv



mkdir -p $DATADIR/{coverpic,final}

SOURCES_LIST="hackernews v2ex solidot zaobao dribbble github ap phoronix"
# for i in $SOURCES_LIST; do
#     mkdir -p $DATADIR/$i
# done


if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


function stdfetch() {
    feedurl="$1"
    fspath="$2"
    if [[ ! -e "$fspath" ]]; then
        curl "$feedurl" > "$fspath"
    else
        echo "[ERROR] Feed file '$fspath' already exists. Delete it to fetch '$sourcename' again." >&2
    fi
}
function rssxmlfetch() {
    feedurl="$1"
    fspath="$DATADIR/$sourcename.xml"
    stdfetch "$feedurl" "$fspath"
}

sourcename="$1"

case $1 in
    '')
        bash $0 coverpic
        bash $0 $SOURCES_LIST
        ;;
    coverpic)
        json_file=$DATADIR/coverpic/random.json
        stdfetch https://api.unsplash.com/photos/random?client_id=$UNSPLASH_API_KEY $json_file
        ;;
    hackernews)
        stdfetch https://hnrss.org/newest.jsonfeed?points=100 $DATADIR/hackernews.json
        ;;
    *)
        ### Fetch generic rss by looking up the table
        tablefn="src/rsstab.psv"
        rssUrl="$(grep "^$1|" $tablefn | cut -d'|' -f2-)"
        if [[ -z "$rssUrl" ]]; then
            echo "[ERROR] Cannot find RSS URL for criteria '$1'"
        else
            rssxmlfetch "$rssUrl"
        fi
    # v2ex)
    #     rssxmlfetch 'https://www.v2ex.com/index.xml'
    #     ;;
    # solidot)
    #     rssxmlfetch 'https://rsshub.app/solidot/linux'
    #     ;;
    # zaobao)
    #     rssxmlfetch 'https://rsshub.app/zaobao/znews/china'
    #     ;;
    # dribbble)
    #     rssxmlfetch 'https://rsshub.app/dribbble/popular/week'
    #     ;;
    # github)
    #     rssxmlfetch 'https://rsshub.app/github/trending/daily/any/any'
    #     ;;
    # ap)
    #     rssxmlfetch 'https://rsshub.app/apnews/topics/ap-top-news'
    #     ;;
    # phoronix)
    #     rssxmlfetch 'https://www.phoronix.com/rss.php'
    #     ;;
    
esac

