const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;
const utils = require('../../.jslib/utils.js');

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`${process.env.DATADIR}/github.xml`));

    const outputLatex = feed.items.map(item => {
        const sanitizedContent = sh(`pandoc -f html -t latex`, { input: item.content.replace(/(<br>)+/g, '<br>') }).toString().trim().split('\n').slice(1).join('\n');
        return (`\\entryitemGithub{\\hskip 0pt{}${sanitizeTextForLatex(item.title)
            }}{${utils.removeUrlHash(item.link)}}`) + `{${sanitizedContent}}`;
    }).filter(utils.killBadWords).join('\n\n');

    fs.writeFileSync(`${process.env.DATADIR}/final/github.tex`, outputLatex);
})();
