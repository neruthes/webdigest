const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`webdb/${process.env.DATEMARK}/zaobao/zaobao.xml`));

    const outputLatex = feed.items.map(item => {
        return sanitizeTextForLatex(`\\entryitemGeneric{\\hskip 0pt{}${item.title}}{${item.link.replace(/\#.+$/, '')}}`);
    }).join('\n\n');

    fs.writeFileSync(`webdb/${process.env.DATEMARK}/final/zaobao.tex`, outputLatex);
})();
