const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;
const utils = require('../../.jslib/utils.js');

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`${process.env.DATADIR}/v2ex.xml`));

    const outputLatex = feed.items.map(item => {
        // Debug
        if (item.title.indexOf('馒头药') >= 0) {
            console.log(item);
        };
        // Return data
        return (`\\entryitemGeneric{\\hskip 0pt{}${
            sanitizeTextForLatex(item.title, { lf: 1 })
        }}{${item.link.replace(/\#.+$/, '')}}`);
    }).filter(utils.killBadWords).join('\n\n');

    fs.writeFileSync(`${process.env.DATADIR}/final/v2ex.tex`, outputLatex);
})();
