(function (me) {
    document.addEventListener(`runlevel${me.dataset.runlevel}`, function () {
        // Initialize DOM pointer
        const preFoCont = document.querySelector('#js-preFooter-container');
        // Generate some sub-containers for different usages
        for (let index = 0; index < 10; index++) {
            preFoCont.innerHTML += `<div id="js-preFooter-${index}"></div>`;
        };

        // Initialize DOM pointer
        const preCoCont = document.querySelector('#js-preContent-container');
        // Generate some sub-containers for different usages
        for (let index = 0; index < 10; index++) {
            preCoCont.innerHTML += `<div id="js-preContent-${index}"></div>`;
        };


        // Regenerate TOC
        document.querySelector('#js-preContent-4').innerHTML = `<nav><div id="navtoc"></div></nav>`;
        const navtoc = document.querySelector('#navtoc');
        const toclist = [...document.querySelectorAll('.pandoc-content > *')].filter(x => x.tagName === 'H2' || x.tagName === 'H3');
        console.log(`toclist:`);
        console.log(toclist);
        toclist.forEach(function (node) {
            navtoc.innerHTML += `<a class="toc-entry" data-toc-entry-class="${node.tagName.toLowerCase()}" href="#${node.id}">${node.innerText}</a>`;
        });

    }, { capture: true });
    me.dataset.isLoaded = 'true';
})(document.currentScript);



