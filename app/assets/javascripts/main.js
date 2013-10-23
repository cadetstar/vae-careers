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

function processSpellcheckErrors(id) {
  if (!!window['currentErrors']) {
    if (window['currentErrors'].length > 0) {
      
      var ce = window['currentErrors'].shift();
      if ($('.spellcheckErrorDisplay').length === 0) {
        $('body').append('<div class="spellcheckErrorDisplay"></div>');
      }
      var t = $('.spellcheckErrorDisplay');
      t.show();
      t.html('');
      t.attr('data-link', id); 
      t.attr('data-line', ce.line);
      t.attr('data-offset', ce.offset);
      t.attr('data-original', ce.original);
      var text = $(id.replace(/&quot;/g, '"')).val().split(/\n/);
      var prev = text[ce.line].slice(0, ce.offset);
      var after = text[ce.line].slice(ce.offset + ce.original.length, text[ce.line].length);
      
      var assembly = '<div class="spellcheckCurrent">';
      for (i = 0; i < text.length; i++) {
        if (i === ce.line) {
          assembly += prev + '<span class="spellcheckCurrentHighlight">' + ce.original + '</span>' + after + '\n';
        } else {
          assembly += text[i] + '\n';
        }
      }
      assembly += '</div>';
      var splits = ce.suggestions.split(',');
      assembly += '<div class="spellcheckIgnore">Ignore (make no change)</div>';
      for (i = 0; i < splits.length; i++) {
        assembly += '<div class="spellcheckChange" data-changeto="' + $.trim(splits[i]) + '">Change to <strong>' + $.trim(splits[i]) + '</strong></div>';
      }
      
      t.html(assembly);
      return;
    }
  }
  $('.spellcheckErrorDisplay').hide();
}

$(document).ready(function() {
  $('[data-spellcheck]').each(function(i, a) {
    var t = new Date();
    var stub = t.getTime().toString() + '-';
    $(a).attr('data-spellcheck', stub + i.toString());
    $(a).after('<br /><a href="#" data-link="' + stub + i.toString() + '" class="spellcheck_link">Check Spelling</a>');
  });

  $(document).on('click', '.spellcheck_link', function(e) {
    e.preventDefault();
    var j = $('[data-spellcheck="' + $(e.target).attr('data-link') + '"]');
    $.get(
      '/spellcheck',
      {
        text: j.val(),
        identifier: '[data-spellcheck="' + $(e.target).attr('data-link').toString() + '"]'
      }
    ); 
  });

  $(document).on('click', '.spellcheckIgnore', function(e) {
    processSpellcheckErrors($('.spellcheckErrorDisplay').attr('data-link')); 
  });

  $(document).on('click', '.spellcheckChange', function(e) {
    var s = $('.spellcheckErrorDisplay');
    var id = s.attr('data-link').replace(/&quot;/g, '"');
    var t = $(id);
    var text = t.val().split(/\n/);
    var line = parseInt(s.attr('data-line'), 10);
    var prev = text[line].slice(0, parseInt(s.attr('data-offset'), 10));
    var after = text[line].slice(parseInt(s.attr('data-offset'), 10) + s.attr('data-original').length, text[line].length);
    text[line] = prev + $(e.target).closest('[data-changeto]').attr('data-changeto') + after;
    t.val(text.join('\n'));

    processSpellcheckErrors($('.spellcheckErrorDisplay').attr('data-link'));
  });
});
