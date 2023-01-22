#!/bin/bash

source .env
source .localenv



mkdir -p $DATADIR/{coverpic,final}

SOURCES_LIST="hackernews v2ex solidot zaobao dribbble github ap phoronix"


if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


function stdfetch() {
    feedurl="$1"
    fspath="$2"
    if [[ ! -e "$fspath" ]] || [[ $OVERWRITE == y ]]; then
        curl -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/109.0' "$feedurl" > "$fspath" || echo "fetch.sh:  Failed to fetch '$feedurl'" >> $BOOMALERT
    else
        echo "[ERROR] Feed file '$fspath' already exists. Delete it to fetch '$sourcename' again." >&2
    fi
    dos2unix "$fspath"
}
function rssxmlfetch() {
    feedurl="$1"
    fspath="$DATADIR/$sourcename.xml"
    stdfetch "$feedurl" "$fspath"
}

sourcename="$1"

case $sourcename in
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
        ;;
esac

