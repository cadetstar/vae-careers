$(document).ready(function() {
    $('.qtip_target').qtip({
        content: {
            attr: 'data-qtip'
//            text: function(api) {
//                alert('firing');
//                return $(this).attr('data-qtip');
//            }
        },
        position: {
            my: 'top left',
            at: 'bottom left'
        },
        show: {
            delay: 500
        }
    });
});