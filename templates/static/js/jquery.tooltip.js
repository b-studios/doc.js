(function($){


  /**
   * Simple jQuery Tooltip Plugin, because most others are oversized.
   * Kudos to http://jqueryfordesigners.com/coda-popup-bubbles/, which fullfilled most of my
   * requirements and serves as copy & paste base for this plugin.
   *
   * Just built a quick and dirty jQuery plugin out of it and refactored the position-calculus.
   */
  $.fn.tooltip = function(options) {  

    var props = {
      distance: 10,
      time: 250,
      hideDelay: 500,
      tooltipSelector: '.tooltip'
    };
    
    $.extend(props, options || {});

    return this.each(function(i, el) {     
     
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
  };
})(jQuery);