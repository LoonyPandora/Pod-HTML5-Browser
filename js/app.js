$(document).ready(function() {
    $('pre code')
        .each(function(i, e) {
        // FIXME: This is an ugly hack because the copy/pasted HTML
        // Has leading spaces on each line of the code blocks
        $(e)
            .text($.trim($(e)
            .text()
            .replace(/\n    /g, '\n')));

        // TODO: This is slow, parses the code twice...
        var highlighter = hljs.highlightAuto($(e)
            .text());

        // Confidence of the auto-detection that the language is correct
        // TODO: Highlight if the second best language is perl
        if (highlighter.r > 1) {
            if (highlighter.language == 'perl') {
                hljs.highlightBlock(e);
            }
        }

    });
});

$('.collapse').on('activate', function() {
    // console.log(this);
});



function isScrolledIntoView(elem) {
    var docViewTop = $(window).scrollTop();
    var elemTop = $(elem).offset().top;
    var scrollAmount = (elemTop - docViewTop);

    if (scrollAmount > 0) {
        console.log(scrollAmount, docViewTop);
        $('#sidebar').scrollTop(scrollAmount);
    }
}


// $('.search-query').quicksearch('.nav-list ul li a', {
//     'delay': 100,
//     show: function() {
//         // console.log($(this).text());
//         
//         // $('<li/>').text($(this).text()).appendTo('.search-results');
//         
//         // $('.search-results')
//         
//         // console.log('show: '+$(this));
//     },
//     hide: function() {
//         // console.log('hide: '+$(this));
//     },
//     'onAfter': function() {
//     },
//     'noResults': 'tr#noresults'
// });
