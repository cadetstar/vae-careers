$(document).ready(function() {
    $('.qtip_target').qtip({
        content: {
            text: function(api) {
                return $(this).attr('data-qtip');
            }
        },
        position: {
            my: 'bottom left',
            at: 'top left'
        },
        show: {
            delay: 500
        }
    });
});