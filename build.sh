#!/bin/bash

source .env
source .localenv

export TZ=UTC
#source "$HOME/.python-venv/bin/activate"


function die() {
    echo "$1" >&2
    exit 1
}


if [[ -n $2 ]]; then
    for i in "$@"; do
        bash "$0" "$i" || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


case $1 in
    redoall)
        if [[ -z "$dothis" ]]; then
            echo "[ERROR] Please set env var 'dothis'."
            exit 1
        fi
        find "webdb/$(date +%Y)" -mindepth 1 -maxdepth 1 -type d | cut -d/ -f3 | sort -r | while read -r FORCEDATE; do
            export FORCEDATE="$FORCEDATE"
            source .env
            $dothis
        done
        ;;
    lastpdf)
        find _dist -name 'WebDigest-*.pdf' | sort -r | head -n1
        ;;
    lastmd)
        find markdown -name 'WebDigest-*.md' | sort -r | head -n1 | xargs realpath
        ;;
    tgmsg)
        source .env
        fn="_dist/tgmsg.txt"
        echo -e "**Web Digest $BETTER_DATEMARK**\n\n" > $fn
        echo -e "PDF:\n$(grep "$DATEMARK.pdf https" .osslist | cut -d' ' -f2)\n\n" >> $fn
        echo -e "HTML:\nhttps://webdigest.pages.dev/readhtml/$THISYEAR/WebDigest-$DATEMARK.html\n\n" >> $fn
        echo -e "Markdown:\nhttps://github.com/neruthes/webdigest/blob/master/markdown/$THISYEAR/WebDigest-$DATEMARK.md" >> $fn
        cp "$fn" ".tmp/tgmsg/$THISYEAR/$DATEMARK.txt"
        pandoc -i "$fn" -f markdown -t html -o _dist/tgmsg.html
        cat "$fn"
        ;;
    tag)
        tag_suffix="$(git tag | grep v$(date +%Y%m) | wc -l)"
        tagname="v$(date +%Y%m).$tag_suffix"
        echo "Command:      $ git tag $tagname && git push origin $tagname"
        echo "URL:          https://github.com/neruthes/webdigest/releases/new"
        echo "Message:      $(bash "$0" count)"
        echo "Artifacts:"
        du -h $(realpath pkgdist/pdfdist-2023.tar)
        ;;
    count)
        echo "Snapshot of PDF artifacts, total count: $(
            find _dist/issue -name '*.pdf' | wc -l
        ), up to $(
            find _dist/issue -name '*.pdf' | sort -r | head -n1 | cut -d/ -f4 | cut -d- -f2 | cut -d. -f1 | date --date=$(cat /dev/stdin) +%F
        )"
        ;;
    ISSUES.md)
        echo -e "# List of Issues\n\n" > ISSUES.md
        IFS=$'\n'
        grep -v .jpg wwwsrc/artifacts-oss.txt | while read -r nojpgfn; do
            # echo "- [$(cut -d/ -f4 <<< $nojpgfn)](https://webdigest.pages.dev/$nojpgfn)" >> ISSUES.md
            pdfid="$(cut -d/ -f4 <<< "$nojpgfn" | cut -d' ' -f1)"
            echo "- [$pdfid]($(cut -d' ' -f2 <<< "$nojpgfn"))" >> ISSUES.md
        done
        cat ISSUES.md
        ;;
    gc)
        du -xhd1 webdb
        max_allowed_pics=50
        # ============================ .tmp
        datenow="$(date +%s)"
        for fn in .tmp/*.{toc,aux,log,out} .tmp/tgmsg; do
            dateOfFile="$(date -r $fn +%s)"
            if [[ $((datenow-dateOfFile)) -gt $((3600*24*4)) ]]; then
                echo "  old file  ($(( (datenow-dateOfFile)/24 ))):  $fn"
            fi
        done
        # ============================ coverpic.jpg
        max_allowed_pics=5
        coverpic_count="$(find webdb -name 'coverpic.jpg' | sort | wc -l)"
        echo "[INFO] Remaining cover pics: $coverpic_count"
        if [[ $coverpic_count -gt $max_allowed_pics ]]; then
            to_delete_quantity=$((coverpic_count-max_allowed_pics))
            echo "[INFO] Will remove $to_delete_quantity files:"
            rm -v $(find webdb -name 'coverpic.jpg' | sort | head -n$to_delete_quantity)
        fi
        # ============================ raw.jpg
        max_allowed_pics=5
        rawpic_count="$(find webdb -name 'raw.jpg' | sort | wc -l)"
        echo "[INFO] Remaining raw cover pics: $rawpic_count"
        if [[ $rawpic_count -gt $max_allowed_pics ]]; then
            to_delete_quantity=$((rawpic_count-max_allowed_pics))
            echo "[INFO] Will remove $to_delete_quantity files:"
            rm -v $(find webdb -name 'raw.jpg' | sort | head -n$to_delete_quantity)
        fi
        # ============================ coverpic-prod.jpg
        max_allowed_pics=7
        prodcoverpic_count="$(find webdb -name 'coverpic-prod.jpg' | sort | wc -l)"
        echo "[INFO] Remaining production cover pics: $prodcoverpic_count"
        if [[ $prodcoverpic_count -gt $max_allowed_pics ]]; then
            to_delete_quantity=$((prodcoverpic_count-max_allowed_pics))
            echo "[INFO] Will remove $to_delete_quantity files:"
            rm -v $(find webdb -name 'coverpic-prod.jpg' | sort | head -n$to_delete_quantity)
        fi
        # ============================ artifact *.pdf.jpg
        max_allowed_pics=50
        pdfcover_count="$(find _dist/issue -name '*.pdf.jpg' | sort | wc -l)"
        echo "[INFO] Remaining dist PDF covers: $pdfcover_count"
        if [[ $pdfcover_count -gt $max_allowed_pics ]]; then
            to_delete_quantity=$((pdfcover_count-max_allowed_pics))
            echo "[INFO] Will remove $to_delete_quantity files:"
            echo rm -v $(find _dist/issue -name '*.pdf.jpg'  | sort | head -n$to_delete_quantity)
            du -h $(find _dist/issue -name '*.pdf.jpg'  | sort | head -n$to_delete_quantity)
        fi
        # ============================
        du -xhd1 webdb
        du -xhd1 _dist
        ;;
    rss)
        function rss_header() {
            cat src/rsslib/header.txt
            echo "<lastBuildDate>$(date -Is)</lastBuildDate>"
        }
        function rss_footer() {
            cat src/rsslib/footer.txt
        }
        function rss_item() {
            pdffn="$1"
            pdfossurl="$2"
            item_id="$(cut -d- -f2 <<< "$pdffn" | cut -d. -f1)"
            item_datemark="$(date --date=$item_id +%Y%m%d)"
            item_betterdatemark="$(date --date=$item_id +%F)"
            item_datetime="$(date --date="$item_id 00:01:00 UTC" -Is)"
            item_pubdate="$(date --date="$item_id 00:01:00 UTC")"
            item_title="Web Digest $item_betterdatemark"
            # echo "debug:
            #     pdffn=$pdffn
            #     pdfossurl=$pdfossurl
            #     item_id=$item_id
            #     item_betterdatemark=$item_betterdatemark
            #     item_datetime=$item_datetime
            #     item_pubdate=$item_pubdate
            # " >&2
            echo "<item>"
            echo "    <title>$item_title</title>"
            echo '    <guid isPermaLink="false">'"https://webdigest.pages.dev/?issuepdf=$item_id"'</guid>'
            echo "    <link>https://webdigest.pages.dev/?issuehtml=$item_id</link>"
            echo "    <pubDate>$item_pubdate</pubDate>"
            echo "    <description>"
            grep -v 'Web Digest ' ".tmp/tgmsg/${item_datemark:0:4}/$item_datemark.txt" |
                sed 's|^https|<https|' |
                sed 's|.html$|.html>|g' |
                sed 's|.md$|.md>|g' |
                sed 's|.pdf$|.pdf>|g' |
                pandoc  -f markdown -t html |
                sed 's|: <a|:<br/><a|g'
            echo "    </description>"
            echo "</item>"
            echo ""
        }
        RSS_FN="wwwsrc/rss.xml"
        rss_header > $RSS_FN
        IFS=$'\n'
        grep '.pdf http' .osslist | sort -r | head -n10 | while read -r pdffn_line; do
            pdffn="$(cut -d' ' -f1 <<< "$pdffn_line")"
            pdfossurl="$(cut -d' ' -f2 <<< "$pdffn_line")"
            rss_item "$pdffn" "$pdfossurl" >> $RSS_FN
        done
        rss_footer >> $RSS_FN
        # cat $RSS_FN
        ;;
    today)
        echo "Today date is  $(date -Is)"
        mkdir -p ".tmp/tgmsg/$(date +%Y)"
        if [[ -e "_dist/issue/$(date +%Y)/WebDigest-$(date +%Y%m%d).pdf" ]]; then
            echo "[ERROR] The PDF artifact of today has been generated already."
            echo "        If you want to proceed, delete _dist/issue/$(date +%Y)/WebDigest-$(date +%Y%m%d).pdf"
            exit 1
        fi
        source "$HOME/.bashrc"
        s5pon h
        bash src/fetch.sh
        bash src/process.sh
        DOWNLOAD=y COMPRESS=y bash src/coverpic.sh
        bash "$0" "$(bash src/make.sh | tail -n1)" # Build target: issue/202X/{...}.tex
        # texfn="$(find issue -name '*.tex' | sort -r | head -n1)"
        # bash "$0" $texfn
        bash src/markdown.sh
        bash "$0" tgmsg gc rss wwwdist deploy pkgdist pkgdist/{web,www}*.tar.zstd
        git add .
        git commit -m "Automatic commit via 'bash build.sh today'"
        git push
        ;;
    issue/*.tex)
        ntex "$1" --2
        pdffn="_dist/${1/.tex/.pdf}"
        # bash "$0" "$(bash "$0" lastpdf)"
        bash "$0" "$pdffn"
        ;;
    _dist/issue/*/*.pdf)
        pdffn="$1"
        echo "$pdffn"
        cfoss "$pdffn" &
        pdftoppm -f 1 -l 1 -singlefile -jpeg "$pdffn" "$pdffn"
        imgfn="$pdffn.jpg"
        magick "$imgfn" -resize x1200 "$imgfn"
        echo "imgfn=$imgfn"
        cfoss "$imgfn" &
        ;;
    wwwdist*)
        echo "[INFO] Building website..."
        function make_indexhtml_for_dirs() {
            DIRSLIST="$(find wwwdist -type d)"
            for DIR in $DIRSLIST; do
                RAWDIR="${DIR:8}"
                # mkdir -p $DIR
                INDEXFILE="$DIR/index.html"
                if [[ ! -e $INDEXFILE ]]; then
                    echo "[INFO] Generating 'index.html' for directory '$RAWDIR'..."
                    sed "s:HTMLTITLE:Web Digest | ${RAWDIR}:" src/htmllib/dirindex.head.html \
                        | sed "s|RAWDIRNAME|$RAWDIR|"  > "$INDEXFILE"
                    for ITEM in $(ls "$DIR" | grep -v 'index.html' | sort -r); do
                        if [[ -d $DIR/$ITEM ]]; then
                            ITEM_SUFFIX="/"
                        else
                            ITEM_SUFFIX=""
                        fi
                        echo "<a class='dirindexlistanchor' href='./$ITEM$ITEM_SUFFIX'>$ITEM$ITEM_SUFFIX</a>" >> "$INDEXFILE"
                    done
                    cat src/htmllib/dirindex.tail.html >> "$INDEXFILE"
                fi
            done
        }
        sed -i 's/oss-r2.neruthes.xyz/pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/g' .osslist
        grep '714f8d634e8f451d9f2fe91a4debfa23.r2.dev/' .osslist | grep 'WebDigest' | grep '_dist/issue' | sed 's/oss-r2.neruthes.xyz/pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/g' | sort -r > wwwsrc/artifacts-oss.txt
        bash "$0" ISSUES.md
        magick _dist/metatex/avatar.pdf.jpg -resize 1024x wwwsrc/favicon.png
        magick _dist/metatex/favicon.pdf.jpg -resize 256x wwwsrc/favicon.ico
        rsync -av --delete wwwsrc/ wwwdist/
        make_indexhtml_for_dirs
        ;;
    pkgdist | pkgdist/ )
        source .env
        echo "[INFO] Producing tarballs..."
        tar --zstd -cf "pkgdist/pdfdist-$THISYEAR.tar.zstd" --exclude "_dist/issue/$THISYEAR/*.jpg" "_dist/issue/$THISYEAR"
        tar --zstd -cf "pkgdist/wwwdist.tar.zstd" wwwdist/
        tar --zstd -cf "pkgdist/webdb.tar.zstd" webdb/
        ;;
    pkgdist/*.*)
        # echo "[INFO] Uploading tarballs..."
        ### We may fix dist package backup later...
        du -h "$1"
        # echo cfoss "$1"
        ;;
    cf | deploy)
        # shareDirToNasPublic
        wrangler pages deploy wwwdist --project-name=webdigest --commit-dirty=true --branch=main
        ;;
    telegram)
        TELEGRAM_BOT_TOKEN
        ;;
    '')
        bash "$0" wwwdist pkgdist deploy
        # shareDirToNasPublic
        bash "$0" pkgdist/{web,www}*.tar.zstd tag
        ;;
esac
