#!/bin/bash

source .env
source .localenv

if [[ ! -e $DATADIR ]]; then
    echo "[ERROR] This date $DATEMARK does not exist?"
    exit 1
fi


md_tex="$DATADIR/to-markdown.tex"
touch $md_tex

output_md="$md_tex.md"

echo "\newcommand{\envdatestr}[0]{$(date '+%F')}
\newcommand{\envfinaldir}[0]{$DATADIR/final}" > $md_tex

cat .texlib/libcmd-v1.tex >> $md_tex



function convert_to_markdown() {
    part_id="$1"
    part_title="$2"
    texpath=$DATADIR/final/$part_id.tex
    if [[ ! -e $texpath ]]; then
        return 0
    fi
    echo "\section{$part_title}" >> $md_tex
    cat $texpath >> $md_tex
}


### Start converting
convert_to_markdown     hackernews      "Hacker News"       
convert_to_markdown     v2ex            "V2EX"       
convert_to_markdown     solidot         "Solidot"       
convert_to_markdown     phoronix        "Phoronix"       
convert_to_markdown     zaobao          "联合早报"       
convert_to_markdown     ap              "AP News"       
convert_to_markdown     github          "GitHub"       
convert_to_markdown     dribbble        "Dribbble"       







pandoc \
    --shift-heading-level-by=1 \
    -i $md_tex \
    -o $output_md


### Post-processing
sed -i 's|plus 11pt minus 1pt||g' $output_md


### Put to final destination
DESTMDDIR="markdown/${DATEMARK:0:4}"
final_output_markdown_fn="$DESTMDDIR/WebDigest-$DATEMARK.md"

echo "[INFO] Generating $final_output_markdown_fn"

mkdir -p "$DESTMDDIR"
# echo "DESTMDDIR=$DESTMDDIR"
# echo "final_output_markdown_fn=$final_output_markdown_fn"
pdfossfn="$(grep "$DATEMARK.pdf https" .osslist | cut -d' ' -f2)"
echo -e "Other formats: [PDF]($pdfossfn) / [HTML](https://webdigest.pages.dev/readhtml/$THISYEAR/WebDigest-$DATEMARK.html)\n\n" > $final_output_markdown_fn
echo -e "# Web Digest $BETTER_DATEMARK\n\n" >> $final_output_markdown_fn
cat $output_md >> $final_output_markdown_fn






### Also make an artifact in HTML

DESTHTMLDIR="${DESTMDDIR/markdown/wwwsrc/readhtml}"
final_output_html_fn="$DESTHTMLDIR/WebDigest-$DATEMARK.html"

echo "[INFO] Generating $final_output_html_fn"

mkdir -p "$DESTHTMLDIR"
cat $final_output_markdown_fn | grep -v 'Other formats' | sed 's|\[\[TOC\]\]||' | grep -v '# Web Digest' | pandoc -f markdown --toc -o $final_output_html_fn.content.html
sed -i 's|color\: blue\!80\!green||g' $final_output_html_fn.content.html
sed -i 's|color\: black\!50|color: #888;|g' $final_output_html_fn.content.html

cat src/htmllib/artifact.header.html |
    sed "s|BETTER_DATEMARK|$BETTER_DATEMARK|g" |
    sed "s|DATEMARK|$DATEMARK|g" |
    sed "s|PDFURL|$pdfossfn|g" > $final_output_html_fn

cat $final_output_html_fn.content.html >> $final_output_html_fn

cat src/htmllib/artifact.footer.html |
    sed "s|BETTER_DATEMARK|$BETTER_DATEMARK|g" |
    sed "s|DATEMARK|$DATEMARK|g" |
    sed "s|PDFURL|$pdfossfn|g" >> $final_output_html_fn

rm $final_output_html_fn.content.html






### Get back to remove heading anchors in the Markdown file
sed -i 's|{#.*.unnumbered}$||' $final_output_markdown_fn
sed -i 's|{style=.*||' $final_output_markdown_fn
sed -i 's|^\[<||' $final_output_markdown_fn
sed -i 's|>]$||' $final_output_markdown_fn
