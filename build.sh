#!/bin/bash


if [[ ! -z $2 ]]; then
    for i in $*; do
        bash $0 $i || die "[ERROR] Some problem happaned."
    done
    exit $?
fi


case $1 in
    today)
        source ~/.bashrc
        s5pon h
        bash src/fetch.js
        DOWNLOAD=y bash src/process.js
        bash src/make.js
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
        find _dist -name '*.pdf' | sort -r > wwwsrc/pdflist.txt
        rsync -av --delete wwwsrc/ wwwdist/
        rsync -av --delete _dist/ wwwdist/_dist/
        ;;
    pkgdist*)
        tar -vcf pkgdist/pdfdist.tar _dist/
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
