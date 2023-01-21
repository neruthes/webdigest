module.exports = {
    sanitizeTextForLatex: function (inputText, opt) {
        if (!opt) {
            opt = {};
        };
        let tmp = inputText;

        // Some operations require explicit declaration
        if (opt.lf) { tmp = tmp.replace(/\n/g, ' ') };

        // Generic operations for all cases
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
