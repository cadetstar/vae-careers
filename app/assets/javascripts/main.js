function checkHeightOfItems(uid) {
    $(uid).css('minHeight', 0);
    var minH = 0;
    $(uid).each(function(i, a) {
        if (minH < $(a).height()) {
            minH = $(a).height();
        }
    });
    $(uid).css('minHeight', minH);
}