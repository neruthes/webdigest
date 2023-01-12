#!/bin/bash

source .env
source .localenv

echo "[INFO] make.sh: Working on '$DATEMARK'..."


[[ -e today ]] && rm today
ln -svf $DATADIR/final today

mkdir -p issue/$THISYEAR

latex_file_path="issue/$THISYEAR/WebDigest-$DATEMARK.tex"

if [[ $THISYEAR == 2023 ]]; then
    COPYRIGHTYEARSRANGE="2023"
else
    COPYRIGHTYEARSRANGE="2023-$THISYEAR"
fi


### Head
sed "s|DATESTRING|$(date '+%F')|g" .texlib/template-v1.tex |
    sed "s|DATEMARK|$DATEMARK|" |
    sed "s|COPYRIGHTYEARSRANGE|$COPYRIGHTYEARSRANGE|" |
    sed "s|DATETHISYEAR|$THISYEAR|" |
    sed "s|FINALDIR|$DATADIR/final|" > "$latex_file_path"



function fill_parts_tex() {
    part_id="$1"
    part_title="$2"
    texpath=$DATADIR/final/$part_id.tex
    if [[ ! -e $texpath ]]; then
        echo "[WARNING] Omitting '$part_id' due to lack of file '$texpath'"
        return 0
    fi
    alltexpath=$DATADIR/final/all.tex
    echo "\section{$part_title}" >> $alltexpath
    cat $texpath >> $alltexpath
}


### Start converting
fill_parts_tex      hackernews      "Hacker News"
fill_parts_tex      v2ex            "V2EX"
fill_parts_tex      solidot         "Solidot"
fill_parts_tex      phoronix        "Phoronix"
fill_parts_tex      zaobao          "联合早报"
fill_parts_tex      ap              "AP News"
fill_parts_tex      github          "GitHub"
fill_parts_tex      dribbble        "Dribbble"

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



