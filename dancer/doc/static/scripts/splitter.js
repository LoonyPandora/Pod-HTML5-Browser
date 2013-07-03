(function ($) {

function addSplitter() {
    var $splitter = $('<div></div>'),
        splitterPos = 330,
        startX, bodyCursor;

    function setPos(pos) {
        $splitter.css('left', pos + 'px');

        $('#content').css('left', (pos + 8) + 'px');
        $('#sidebar').css('width', pos + 'px');
        $('.route-panel > h3').css('left', (370 - 330 + 8 + pos) + 'px');
        $('#sidebar > ul').css('width', (500 - 330 + pos) + 'px');

        splitterPos = pos;

        if (window.localStorage)
            localStorage.setItem('splitterPos', splitterPos);
    }

    if (window.localStorage)
        splitterPos = parseInt(localStorage.getItem('splitterPos') || 330);

    $splitter.css({
        backgroundColor: '#ddd',
        borderLeft: 'solid 1px #eee',
        borderTop: 'solid 1px #eee',
        borderRight: 'solid 1px #bbb',
        borderBottom: 'solid 1px #bbb',
        bottom: 0,
        color: '#888',
        cursor: 'ew-resize',
        height: '100%',
        position: 'absolute',
        width: '6px'
    });

    $splitter.insertBefore($('#content'));

    $splitter
        .mousedown(function (event) {
            startX = event.pageX;
            bodyCursor = $('body').css('cursor');
            $('body').css('cursor', 'ew-resize');
            return false;
        })

    $(document)
        .mousemove(function (event) {
            if (startX !== undefined) {
                setPos(splitterPos + event.pageX - startX);
                startX = event.pageX;
            }
            return false;
        })
        .mouseup(function (event) {
            startX = undefined;
            $('body').css('cursor', bodyCursor);
        });

    setPos(splitterPos);
}

$(function () {
    addSplitter();
});

})(jQuery);
