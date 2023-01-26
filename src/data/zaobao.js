const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;
const utils = require('../../.jslib/utils.js');

let Parser = require('rss-parser');
let parser = new Parser();

(async () => {
    let feed = await parser.parseString(fs.readFileSync(`${process.env.DATADIR}/zaobao.xml`));

    const outputLatex = feed.items.map(item => {
        const sanitizedContent = sh(`pandoc -f html -t latex`, {
            input: item.contentSnippet.split('<style>')[0]
        }).toString().replace(/\n/g, ' ').split('.cta-subscribe')[0]
            .replace('请订阅或登录，以继续阅读全文！', '').slice(0, 200).trim()
            .replace(/[。？！…][^。？！…]*?$/, '……');
        return (`\\entryitemWithDescription{${sanitizeTextForLatex(item.title)}}{${utils.removeUrlHash(item.link)}}{${sanitizedContent}}`);
    }).filter(utils.killBadWords).join('\n\n');

    fs.writeFileSync(`${process.env.DATADIR}/final/zaobao.tex`, outputLatex);
})();
