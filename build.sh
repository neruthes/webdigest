#!/bin/bash


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
    today)
        source $HOME/.bashrc
        s5pon h
        bash src/fetch.sh
        DOWNLOAD=y bash src/process.sh
        bash $0 "$(bash src/make.sh | tail -n1)"
        # texfn="$(find issue -name '*.tex' | sort -r | head -n1)"
        # bash $0 $texfn
        bash $0 wwwdist pkgdist deploy pkgdist/*.*
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
        mv "$imgfn" "$pdffn.jpg"
        cfoss "$pdffn.jpg"
        # echo "wanted rangedfn=/tmp/http/pdfrange/issue-20230107_page1-1.pdf"
        # echo "actual rangedfn=$rangedfn"
        ;;
    wwwdist*)
        grep oss-r2 .osslist | grep WebDigest | sed 's/oss-r2.neruthes.xyz/pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/g' | sort -r > wwwsrc/pdflist-oss.txt
        bash $0 ISSUES.md
        rsync -av --delete wwwsrc/ wwwdist/
        ;;
    pkgdist | pkgdist/ )
        tar -vcf pkgdist/pdfdist.tar --exclude '_dist/issue/*/*.jpg' _dist/
        tar -vcf pkgdist/wwwdist.tar wwwdist/
        cd wwwdist
        zip -9vr ../pkgdist/wwwdist .
        ;;
    pkgdist/*.*)
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
