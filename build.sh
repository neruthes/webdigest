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
        for i in $(find _dist -name '*.pdf' | sort -r); do
            echo "- [$(cut -d/ -f4 <<< $i)](https://webdigest.pages.dev/$i)" >> ISSUES.md
        done
        cat ISSUES.md
        ;;
    today)
        source ~/.bashrc
        s5pon h
        bash src/fetch.sh
        DOWNLOAD=y bash src/process.sh
        bash src/make.sh
        texfn="$(find issue -name '*.tex' | sort -r | head -n1)"
        bash $0 $texfn
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
        # echo "wanted rangedfn=/tmp/http/pdfrange/issue-20230107_page1-1.pdf"
        # echo "actual rangedfn=$rangedfn"
        ;;
    wwwdist*)
        bash $0 ISSUES.md
        find _dist -name '*.pdf' | sort -r > wwwsrc/pdflist.txt
        rsync -av --delete wwwsrc/ wwwdist/
        rsync -av --delete _dist/ wwwdist/_dist/
        ;;
    pkgdist*)
        tar -vcf pkgdist/pdfdist.tar --exclude '_dist/issue/*/*.jpg' _dist/
        tar -vcf pkgdist/wwwdist.tar wwwdist/
        cd wwwdist
        zip -9vr ../pkgdist/wwwdist .
        ;;
    deploy)
        shareDirToNasPublic
        wrangler pages publish wwwdist --project-name=webdigest --commit-dirty=true
        for i in pkgdist/*; do
            cfoss $i
        done
        ;;
    '')
        bash $0 wwwdist pkgdist deploy
        shareDirToNasPublic
        ;;
esac
