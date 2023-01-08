const fs = require('fs');
const sh = require('child_process').execSync;
const sanitizeTextForLatex = require('../../.jslib/sanitizeTextForLatex.js').sanitizeTextForLatex;

let fetchedData = JSON.parse(fs.readFileSync(`webdb/${process.env.DATEMARK}/hackernews/newest.json`).toString());


const outputLatex = fetchedData.items.map(function (item) {
    return sanitizeTextForLatex(`\\entryitemHackernews{\\hskip 0pt{}${item.title}}{${item.id}}{${item.url}}`);
}).join('\n\n');


fs.writeFileSync(`webdb/${process.env.DATEMARK}/final/hackernews.tex`, outputLatex);
