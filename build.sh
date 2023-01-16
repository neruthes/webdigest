#!/bin/bash

export TZ=UTC


function die() {
    echo "$1" >&2
    exit 1
}


if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


case $1 in
    lastpdf)
        realpath $(find _dist -name '*.pdf' | sort -r | head -n1)
        ;;
    tgmsg)
        source .env
        fn=".tmp/tgmsg/$THISYEAR/$DATEMARK.txt"
        fn2="_dist/tgmsg.txt"
        mkdir -p ".tmp/tgmsg/$THISYEAR"
        printf "**Web Digest $BETTER_DATEMARK**\n\n" > $fn
        printf "PDF:\n$(grep "$DATEMARK.pdf https" .osslist | cut -d' ' -f2)\n\n" >> $fn
        printf "HTML:\nhttps://webdigest.pages.dev/readhtml/$THISYEAR/WebDigest-$DATEMARK.html\n\n" >> $fn
        printf "Markdown:\nhttps://github.com/neruthes/webdigest/blob/master/markdown/$THISYEAR/WebDigest-$DATEMARK.md" >> $fn
        cp $fn $fn2
        cp $fn _dist/tgmsg.txt
        pandoc -i _dist/tgmsg.txt -f markdown -t html -o _dist/tgmsg.html
        cat $fn
        ;;
    tag)
        tag_suffix="$(git tag | grep v$(date +%Y%m) | wc -l)"
        tagname="v$(date +%Y%m).$tag_suffix"
        echo git tag $tagname
        echo git push origin $tagname
        echo "https://github.com/neruthes/webdigest/releases/new"
        bash $0 count
        du -h "$(realpath pkgdist/pdfdist.tar)"
        ;;
    count)
        echo "Snapshot of PDF artifacts, total count: $(
            find _dist -name '*.pdf' | wc -l
        ), up to $(
            find _dist -name '*.pdf' | sort -r | head -n1 | cut -d/ -f4 | cut -d- -f2 | cut -d. -f1 | date --date=$(cat /dev/stdin) +%F
        )"
        ;;
    ISSUES.md)
        echo -e "# List of Issues\n\n" > ISSUES.md
        IFS=$'\n'
        for i in $(cat wwwsrc/artifacts-oss.txt | grep -v .jpg); do
            # echo "- [$(cut -d/ -f4 <<< $i)](https://webdigest.pages.dev/$i)" >> ISSUES.md
            pdfid="$(cut -d/ -f4 <<< "$i" | cut -d' ' -f1)"
            echo "- [$pdfid]($(cut -d' ' -f2 <<< "$i"))" >> ISSUES.md
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
            echo "<lastBuildDate>$(date)</lastBuildDate>"
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
            echo "    <link>https://webdigest.pages.dev/?issuepdf=$item_id</link>"
            echo "    <pubDate>$item_pubdate</pubDate>"
            echo "    <description>"
            cat .tmp/tgmsg/${item_datemark:0:4}/$item_datemark.txt |
                grep -v 'Web Digest ' |
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
        RSS_FN=wwwsrc/rss.xml
        rss_header > $RSS_FN
        IFS=$'\n'
        for pdffn_line in $(grep '.pdf http' .osslist | sort -r); do
            pdffn="$(cut -d' ' -f1 <<< "$pdffn_line")"
            pdfossurl="$(cut -d' ' -f2 <<< "$pdffn_line")"
            rss_item "$pdffn" "$pdfossurl" >> $RSS_FN
        done
        rss_footer >> $RSS_FN
        cat $RSS_FN
        ;;
    today)
        if [[ -e "_dist/issue/$(date +%Y)/WebDigest-$(date +%Y%m%d).pdf" ]]; then
            echo "[ERROR] The PDF artifact of today has been generated already."
            echo "        If you want to proceed, delete _dist/issue/$(date +%Y)/WebDigest-$(date +%Y%m%d).pdf"
            exit 1
        fi
        source $HOME/.bashrc
        s5pon h
        bash src/fetch.sh
        bash src/process.sh
        DOWNLOAD=y COMPRESS=y bash src/coverpic.sh
        bash $0 "$(bash src/make.sh | tail -n1)"
        # texfn="$(find issue -name '*.tex' | sort -r | head -n1)"
        # bash $0 $texfn
        bash src/markdown.sh
        bash $0 tgmsg gc rss wwwdist deploy pkgdist pkgdist/*.*
        git add .
        git commit -m "Automatic commit via 'bash build.sh today'"
        git push
        ;;
    issue/*.tex)
        ntex $1 --2 --oss
        pdffn="_dist/${1/.tex/.pdf}"
        # echo "$pdffn"
        pdfrange $pdffn 1-1
        rangedfn="/tmp/http/pdfrange/$(basename "$pdffn")"
        rangedfn="$(sed 's|.pdf$|_page1-1.pdf|' <<< "$rangedfn")"
        pdftoimg "$rangedfn"
        imgfn="$rangedfn.jpg"
        convert "$imgfn" -resize x1200 "$pdffn.jpg"
        cfoss "$pdffn.jpg"
        # echo "wanted rangedfn=/tmp/http/pdfrange/issue-20230107_page1-1.pdf"
        # echo "actual rangedfn=$rangedfn"
        ;;
    _dist/issue/*/*.pdf)
        pdffn="$1"
        # echo "$pdffn"
        pdfrange $pdffn 1-1
        rangedfn="/tmp/http/pdfrange/$(basename "$pdffn")"
        rangedfn="$(sed 's|.pdf$|_page1-1.pdf|' <<< "$rangedfn")"
        pdftoimg "$rangedfn"
        imgfn="$rangedfn.jpg"
        convert "$imgfn" -resize x1200 "$pdffn.jpg"
        cfoss "$pdffn.jpg"
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
                        | sed "s|RAWDIRNAME|$RAWDIR|"  > $INDEXFILE
                    for ITEM in $(ls $DIR | grep -v 'index.html' | sort -r); do
                        if [[ -d $DIR/$ITEM ]]; then
                            ITEM_SUFFIX="/"
                        else
                            ITEM_SUFFIX=""
                        fi
                        echo "<a class='dirindexlistanchor' href='./$ITEM$ITEM_SUFFIX'>$ITEM$ITEM_SUFFIX</a>" >> $INDEXFILE
                    done
                    cat src/htmllib/dirindex.tail.html >> $INDEXFILE
                fi
            done
        }
        grep 'oss-r2' .osslist | grep 'WebDigest' | grep '_dist/issue' | sed 's/oss-r2.neruthes.xyz/pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/g' | sort -r > wwwsrc/artifacts-oss.txt
        bash $0 ISSUES.md
        rsync -av --delete wwwsrc/ wwwdist/
        make_indexhtml_for_dirs
        ;;
    pkgdist | pkgdist/ )
        echo "[INFO] Producing tarballs..."
        tar -cf pkgdist/pdfdist.tar --exclude '_dist/issue/*/*.jpg' _dist/
        tar -cf pkgdist/wwwdist.tar wwwdist/
        tar -cf pkgdist/webdb.tar webdb/
        ;;
    pkgdist/*.*)
        echo "[INFO] Uploading tarballs..."
        cfoss $1
        ;;
    deploy)
        shareDirToNasPublic
        wrangler pages publish wwwdist --project-name=webdigest --commit-dirty=true --branch=main
        # for i in pkgdist/*; do
        #     cfoss $i
        # done
        ;;
    '')
        bash $0 wwwdist pkgdist deploy
        shareDirToNasPublic
        ;;
esac
