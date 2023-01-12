#!/bin/bash

source .env
source .localenv


md_tex="$DATADIR/to-markdown.tex"
touch $md_tex

output_md="$md_tex.md"

echo "\newcommand{\envdatestr}[0]{$(date '+%F')}
\newcommand{\envfinaldir}[0]{$DATADIR/final}" > $md_tex

cat .texlib/libcmd-v1.tex >> $md_tex



function convert_to_markdown() {
    part_id="$1"
    part_title="$2"
    echo "\section{$part_title}" >> $md_tex
    cat $DATADIR/final/$part_id.tex >> $md_tex
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







echo $md_tex

pandoc \
    --shift-heading-level-by=1 \
    -i $md_tex \
    -o $output_md


### Post-processing
sed -i 's|plus 11pt minus 1pt||g' $output_md


### Put to final destination
DESTMDDIR="markdown/${DATEMARK:0:4}"
final_output_markdown_fn="$DESTMDDIR/WebDigest-$DATEMARK.md"
mkdir -p "$DESTMDDIR"
# echo "DESTMDDIR=$DESTMDDIR"
# echo "final_output_markdown_fn=$final_output_markdown_fn"
echo -e "# WebDigest $BETTER_DATEMARK\n\n" > $final_output_markdown_fn
cat $output_md >> $final_output_markdown_fn






### Also make an artifact in HTML

DESTHTMLDIR="${DESTMDDIR/markdown/wwwsrc/readhtml}"
final_output_html_fn="$DESTHTMLDIR/WebDigest-$DATEMARK.html"
mkdir -p "$DESTHTMLDIR"
cat $final_output_markdown_fn | sed 's|\[\[TOC\]\]||' | grep -v '# WebDigest' | pandoc -f markdown --toc -o $final_output_html_fn.content.html

cat src/htmllib/artifact.header.html |
    sed "s|BETTER_DATEMARK|$BETTER_DATEMARK|g" |
    sed "s|DATEMARK|$DATEMARK|g" |
    sed "s|PDFURL|https://webdigest.pages.dev/?issuepdf=$DATEMARK|g" > $final_output_html_fn

cat $final_output_html_fn.content.html >> $final_output_html_fn

cat src/htmllib/artifact.footer.html |
    sed "s|BETTER_DATEMARK|$BETTER_DATEMARK|g" |
    sed "s|DATEMARK|$DATEMARK|g" |
    sed "s|PDFURL|https://webdigest.pages.dev/?issuepdf=$DATEMARK|g" >> $final_output_html_fn

rm $final_output_html_fn.content.html





### Get back to remove heading anchors in the Markdown file
sed -i 's|{#.*.unnumbered}$||' $final_output_markdown_fn
sed -i 's|{style=.*||' $final_output_markdown_fn
sed -i 's|^\[<||' $final_output_markdown_fn
sed -i 's|>]$||' $final_output_markdown_fn
