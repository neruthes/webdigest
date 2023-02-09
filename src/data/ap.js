const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;
const utils = require('../../.jslib/utils.js');

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`${process.env.DATADIR}/ap.xml`));
    
    const outputLatex = feed.items.map(item => {
        const sanitizedContent = sh(`pandoc -f html -t latex`, {
            input: item.contentSnippet
        }).toString().replace(/\n/g, ' ').trim().slice(0, 240).replace(/[^\w]*$/, '').replace(/[\\\-\s\,\.\(\)]*?[\w\,]+?$/, '...');
        const shorturl = 'https://apnews.com/article/' + item.link.match(/\w+$/)[0];
        return (`\\entryitemWithDescription{\\hskip 0pt{}${
            sanitizeTextForLatex(item.title)
        }}{${shorturl}}`) + `{${sanitizedContent}}`;
    }).filter(utils.killBadWords).slice(0, 13).join('\n\n');

    fs.writeFileSync(`${process.env.DATADIR}/final/ap.tex`, outputLatex);
})();
