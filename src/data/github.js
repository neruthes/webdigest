const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;

let Parser = require('rss-parser');
let parser = new Parser();


(async () => {
    let feed = await parser.parseString(fs.readFileSync(`webdb/${process.env.DATEMARK}/github/github.xml`));
    
    const outputLatex = feed.items.map(item => {
        const sanitizedContent = sh(`pandoc -f html -t latex`, { input: item.content }).toString().trim().split('\n').slice(1).join('\n');
        // console.log(sanitizedContent)
        return sanitizeTextForLatex(`\\entryitemGithub{\\hskip 0pt{}${item.title}}{${item.link.replace(/\#.+$/, '')}}{${sanitizedContent}}`);
    }).join('\n\n');

    // console.log(feed.items[0]);

    fs.writeFileSync(`webdb/${process.env.DATEMARK}/final/github.tex`, outputLatex);
})();
