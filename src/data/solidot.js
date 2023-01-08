const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex; 

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`${process.env.DATADIR}/solidot/solidot.xml`));

    const outputLatex = feed.items.map(item => {
        return sanitizeTextForLatex(`\\entryitemGeneric{\\hskip 0pt{}${item.title}}{${item.link.replace(/\#.+$/, '')}}`);
    }).join('\n\n');

    fs.writeFileSync(`${process.env.DATADIR}/final/solidot.tex`, outputLatex);
})();
