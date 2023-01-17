#!/bin/bash

source .env
source .localenv

echo "[INFO] make.sh: Working on '$DATEMARK'..."


[[ -e today ]] && rm today
ln -svf $DATADIR/final today

mkdir -p issue/$THISYEAR

latex_file_path="issue/$THISYEAR/WebDigest-$DATEMARK.tex"


### Head
sed "s|DATESTRING|$(date --date=$DATEMARK '+%F')|g" .texlib/template-v1.tex |
    sed "s|DATEMARK|$DATEMARK|" |
    sed "s|COPYRIGHTYEARSRANGE|$COPYRIGHTYEARSRANGE|" |
    sed "s|DATETHISYEAR|$THISYEAR|" |
    sed "s|FINALDIR|$DATADIR/final|" > "$latex_file_path"



function fill_chapter_tex() {
    chapter_id="$1"
    chapter_title="$2"
    texpath="$DATADIR/final/$chapter_id.tex"
    if [[ ! -e $texpath ]]; then
        echo "[WARNING] Omitting '$chapter_id' due to lack of file '$texpath'"
        return 0
    fi
    echo "\ichapter{$chapter_title}" >> $output_tex_path
    cat $texpath >> $output_tex_path
}
function fill_part_tex() {
    part_title="$1"
    echo "\ipart{$part_title}" >> $output_tex_path
}


output_tex_path="$DATADIR/final/all.tex"
printf "" > $output_tex_path
fill_part_tex           "Developers"
fill_chapter_tex        hackernews      "Hacker News"
fill_chapter_tex        phoronix        "Phoronix"
fill_chapter_tex        github          "GitHub"
fill_chapter_tex        dribbble        "Dribbble"
fill_part_tex           "Developers~~~~(zh-Hans)"
fill_chapter_tex        solidot         "Solidot"
fill_chapter_tex        v2ex            "V2EX"
fill_part_tex           "Generic News"
fill_chapter_tex        ap              "AP News"
fill_chapter_tex        zaobao          "联合早报"

# \ipart{Hacker News}
# \input{FINALDIR/hackernews.tex}

# \ipart{V2EX}
# \input{FINALDIR/v2ex.tex}

# \ipart{Solidot}
# \input{FINALDIR/solidot.tex}

# \ipart{Phoronix}
# \input{FINALDIR/phoronix.tex}

# \ipart{联合早报}
# \input{FINALDIR/zaobao.tex}

# \ipart{AP News}
# \input{FINALDIR/ap.tex}

# \ipart{GitHub}
# \input{FINALDIR/github.tex}

# \ipart{Dribbble}
# \input{FINALDIR/dribbble.tex}


echo $latex_file_path



