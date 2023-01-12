#!/bin/bash

export TZ=UTC


if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


case $1 in
    tag)
        tag_suffix="$(git tag | grep v$(date +%Y%m) | wc -l)"
        tagname="v$(date +%Y%m).$tag_suffix"
        echo git tag $tagname
        echo git push origin $tagname
        echo "https://github.com/neruthes/webdigest/releases/new"
        bash $0 count
        ;;
    count)
        echo "Snapshot of PDF artifacts, total count: $(
            find _dist -name '*.pdf' | wc -l
        ), up to $(
            find _dist -name '*.pdf' | sort -r | head -n1 | cut -d/ -f4 | cut -d- -f2 | cut -d. -f1
        )"
        ;;
    ISSUES.md)
        echo -e "# List of Issues\n\n" > ISSUES.md
        IFS=$'\n'
        for i in $(cat wwwsrc/pdflist-oss.txt | grep -v .jpg); do
            # echo "- [$(cut -d/ -f4 <<< $i)](https://webdigest.pages.dev/$i)" >> ISSUES.md
            pdfid="$(cut -d/ -f4 <<< "$i" | cut -d' ' -f1)"
            echo "- [$pdfid]($(cut -d' ' -f2 <<< "$i"))" >> ISSUES.md
        done
        cat ISSUES.md
        ;;
    gc)
        du -xhd1 webdb
        max_allowed_pics=2
        # ============================
        coverpic_count="$(find webdb -name 'coverpic.jpg' | sort | wc -l)"
        echo "[INFO] Remaining cover pics: $coverpic_count"
        if [[ $coverpic_count -gt $max_allowed_pics ]]; then
            to_delete_quantity=$((coverpic_count-max_allowed_pics))
            echo "[INFO] Will remove $to_delete_quantity files:"
            rm -v $(find webdb -name 'coverpic.jpg' | sort | head -n$to_delete_quantity)
        fi
        # ============================
        rawpic_count="$(find webdb -name 'raw.jpg' | sort | wc -l)"
        echo "[INFO] Remaining raw cover pics: $rawpic_count"
        if [[ $rawpic_count -gt $max_allowed_pics ]]; then
            to_delete_quantity=$((rawpic_count-max_allowed_pics))
            echo "[INFO] Will remove $to_delete_quantity files:"
            rm -v $(find webdb -name 'raw.jpg' | sort | head -n$to_delete_quantity)
        fi
        # ============================
        prodcoverpic_count="$(find webdb -name 'coverpic-prod.jpg' | sort | wc -l)"
        echo "[INFO] Remaining production cover pics: $prodcoverpic_count"
        if [[ $prodcoverpic_count -gt $max_allowed_pics ]]; then
            to_delete_quantity=$((prodcoverpic_count-max_allowed_pics))
            echo "[INFO] Will remove $to_delete_quantity files:"
            rm -v $(find webdb -name 'coverpic-prod.jpg' | sort | head -n$to_delete_quantity)
        fi
        # ============================
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
            echo "<lastBuildDate>$(TZ=UTC date)</lastBuildDate>"
        }
        function rss_footer() {
            cat src/rsslib/footer.txt
        }
        function rss_item() {
            pdffn="$1"
            pdfossurl="$2"
            item_id="$(cut -d- -f2 <<< "$pdffn" | cut -d. -f1)"
            item_datemark="$(TZ=UTC date --date=$item_id +%F)"
            item_datetime="$(TZ=UTC date --date="$item_id 00:01:00 UTC" -Is)"
            item_pubdate="$(TZ=UTC date --date="$item_id 00:01:00 UTC")"
            item_title="WebDigest $item_datemark has been released"
            echo "debug:
                pdffn=$pdffn
                pdfossurl=$pdfossurl
                item_id=$item_id
                item_datemark=$item_datemark
                item_datetime=$item_datetime
                item_pubdate=$item_pubdate
            " >&2
            # pdfossurl="$(grep "$(basename $pdffn) " .osslist | cut -d' ' -f2)"
            echo "<item>"
            echo "    <title><![CDATA[$item_title]]></title>"
            echo '    <guid isPermaLink="false">'"https://webdigest.pages.dev/?issuepdf=$item_id"'</guid>'
            echo "    <link>https://webdigest.pages.dev/?issuepdf=$item_id</link>"
            echo "    <pubDate>$item_pubdate</pubDate>"
            # <pubDate>Wed, 11 Jan 2023 15:02:28 GMT</pubDate>
            echo "    <description>"
            echo "<p>Dear subscriber,</p>
                <p>WebDigest $item_datemark has been released.</p>
                <p>Link: <a href=\"$pdfossurl\">$pdfossurl</a></p>"
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
        if [[ -e "_dist/issue/$(TZ=UTC date +%Y)/WebDigest-$(TZ=UTC date +%Y%m%d).pdf" ]]; then
            echo "[ERROR] The PDF artifact of today has been generated already."
            echo "        If you want to proceed, delete _dist/issue/$(date +%Y)/WebDigest-$(date +%Y%m%d).pdf"
            exit 1
        fi
        source $HOME/.bashrc
        s5pon h
        bash src/fetch.sh
        DOWNLOAD=y bash src/process.sh
        bash $0 "$(bash src/make.sh | tail -n1)"
        # texfn="$(find issue -name '*.tex' | sort -r | head -n1)"
        # bash $0 $texfn
        bash $0 gc rss wwwdist deploy pkgdist pkgdist/*.*
        git add .
        git commit -m "Automatic commit via bash build.sh today"
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
    wwwdist*)
        echo "[INFO] Building website..."
        grep oss-r2 .osslist | grep WebDigest | sed 's/oss-r2.neruthes.xyz/pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/g' | sort -r > wwwsrc/pdflist-oss.txt
        bash $0 ISSUES.md
        rsync -av --delete wwwsrc/ wwwdist/
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
