const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;
const utils = require('../../.jslib/utils.js');

let fetchedData = JSON.parse(fs.readFileSync(`${process.env.DATADIR}/hackernews.json`).toString());


const outputLatex = fetchedData.items.map(function (item) {
    return (`\\entryitemHackernews{${sanitizeTextForLatex(item.title)}}{${sanitizeTextForLatex(item.id)}}{${sanitizeTextForLatex(item.url)}}`);
}).filter(utils.killBadWords).join('\n\n');


fs.writeFileSync(`${process.env.DATADIR}/final/hackernews.tex`, outputLatex);
