const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;
const utils = require('../../.jslib/utils.js');

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`${process.env.DATADIR}/dribbble.xml`));

    const outputLatex = feed.items.map(item => {
        return (`\\entryitemGeneric{\\hskip 0pt{}${sanitizeTextForLatex(item.title, { lf: 1 })
            }}{${utils.removeUrlHash(item.link)
            }}`);
    }).filter(utils.killBadWords).join('\n\n');

    fs.writeFileSync(`${process.env.DATADIR}/final/dribbble.tex`, outputLatex);
})();
