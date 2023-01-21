module.exports = {
    killBadWords: function (inputText) {
        // This function shall be used as ARRAY.filter(utils.killBadWords).join('\n\n')
        const badwords = [
            '习近平',
            'Jinping',
            '中共',
            'Communist Party',
        ];
        for (let i = 0; i < badwords.length; i++) {
            if (inputText.indexOf(badwords[i]) !== -1) {
                // Found a bad word!
                console.log(`[WARNING] Found a bad word: ${badwords[i]}`);
                console.log(`Input text: ${inputText}`);
                return false;
            };
        }
        return true;
    },
    removeUrlHash: function (inputUrl) {
        return inputUrl.replace(/\#.+$/, '');
    }
}
