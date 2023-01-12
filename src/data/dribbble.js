const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;
const utils = require('../../.jslib/utils.js');

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`${process.env.DATADIR}/dribbble/dribbble.xml`));

    const outputLatex = feed.items.map(item => {
        return sanitizeTextForLatex(`\\entryitemGeneric{\\hskip 0pt{}${item.title}}{${item.link.replace(/\#.+$/, '')}}`);
    }).filter(utils.killbadwords).join('\n\n');

    fs.writeFileSync(`${process.env.DATADIR}/final/dribbble.tex`, outputLatex);
})();
