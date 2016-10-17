var setupTableOfContents = function() {
  var $tocToggle = $('[data-role="table-of-contents-toggle"]');
  var $tocClose = $('[data-role="table-of-contents-close"]');
  var $toc = $('[data-role="table-of-contents"]');
  var $body = $('body');

  var closeToc = function() {
    $toc.removeClass('slide-down');
    $tocToggle.removeClass('is-open');
    $body.removeClass('has-table-of-contents');
  };

  var openToc = function() {
    $toc.addClass('slide-down');
    $tocToggle.addClass('is-open');
    $body.addClass('has-table-of-contents');
  };

  $tocToggle.off('click');
  $tocToggle.click(function() {
    if ($tocToggle.hasClass('is-open')) {
      closeToc();
    } else {
      openToc();
    }
    return false;
  });

  $tocClose.click(function() {
    closeToc();
    return false;
  });
};

$(function() {
  setupTableOfContents();
  var header = '.sticky-header';

  if ($(header).length) {
    new Headhesive(header, {
      offset:  window.stickyHeaderStart || 100,
      onStick: setupTableOfContents,
      onUnstick: setupTableOfContents,
    });
  }
});
