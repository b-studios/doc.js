

$(function() {  

  var header = $("#header"),
      showButton = header.find("a.expand"),
      hideButton = header.find("a.collapse");

  header.find("#api-browser > ul").treeview({
    collapsed: true, 
    animated: 'fast',
    persist: 'cookie'
  });
  
  hideButton.click(function() {
    header.addClass("collapsed");
    hideButton.hide();
    showButton.show();
  });
  
  showButton.click(function() {
    header.removeClass("collapsed");
    hideButton.show();
    showButton.hide();
  });
    
    
    /* @todo refactor this one as jquery plugin, reference to http://jqueryfordesigners.com/coda-popup-bubbles/ */
    
  $('.signature .params .param').each(function (i, el) {

    var props = {
      distance: 10,
      time: 250,
      hideDelay: 500,
      tooltipSelector: '.tooltip'
    };
    
    var hideDelayTimer = null;

    var beingShown = false;
    var shown = false;
    var trigger = $(el);
    var info = trigger.next(props.tooltipSelector);

    $([trigger.get(0), info.get(0)]).mouseover(function (evt) {
    
        // calculate target position    
        var targetLeft = (evt.pageX - trigger.offset().left) + trigger.position().left - (info.width()/2);
        var targetTop = trigger.position().top - info.height();
    
        if (hideDelayTimer) clearTimeout(hideDelayTimer);
        if (beingShown || shown) {
            // don't trigger the animation again
            return;
        } else {
            // reset position of info box
            beingShown = true;

            info.css({
                top: targetTop,
                left: targetLeft,
                display: 'block'
            }).animate({
                top: '-=' + props.distance + 'px',
                opacity: 1
            }, props.time, 'swing', function() {
                beingShown = false;
                shown = true;
            });
        }

        return false;
        
    }).mouseout(function () {
        if (hideDelayTimer) clearTimeout(hideDelayTimer);
        hideDelayTimer = setTimeout(function () {
            hideDelayTimer = null;
            info.animate({
                top: '-=' + props.distance + 'px',
                opacity: 0
            }, props.time, 'swing', function () {
                shown = false;
                info.css('display', 'none');
            });

        }, props.hideDelay);

        return false;
    });
  }); 
});