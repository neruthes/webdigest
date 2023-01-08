module.exports = {
    sanitizeTextForLatex: function (inputText) {
        let tmp = inputText;
        tmp = tmp.replace(/\&/g, '\\&');
        tmp = tmp.replace(/\_/g, '\\_');
        tmp = tmp.replace(/“/g, '``');
        tmp = tmp.replace(/”/g, `''`);
        tmp = tmp.replace(/‘/g, '`');
        tmp = tmp.replace(/’/g, `'`);
        tmp = tmp.replace(/\$/g, `\\$`);
        tmp = tmp.replace(/%/g, `\\%`);
        tmp = tmp.replace(/\#/g, `\\#`);
        return tmp;
    }
}
