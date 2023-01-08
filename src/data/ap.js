const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;

let Parser = require('rss-parser');
let parser = new Parser();


(async () => {
    let feed = await parser.parseString(fs.readFileSync(`webdb/${process.env.DATEMARK}/ap/ap.xml`));
    
    const outputLatex = feed.items.map(item => {
        const sanitizedContent = sh(`pandoc -f html -t latex`, {
            input: item.contentSnippet
        }).toString().replace(/\n/g, ' ').trim().slice(0, 220).replace(/[\-\s\,\.\(\)]*?[\w\,]+?$/, '...');
        // console.log(sanitizedContent)
        return sanitizeTextForLatex(`\\entryitemAp{\\hskip 0pt{}${item.title}}{${item.link.replace(/\#.+$/, '')}}`) + `{${sanitizedContent}}`;
    }).join('\n\n');

    // console.log(feed.items[0]);

    fs.writeFileSync(`${process.env.DATADIR}/final/ap.tex`, outputLatex);
})();
