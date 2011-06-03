J.modules = J.modules || {}; 

J.create('Module', {

  constructor: function(name, module_init, options) {
        
    options = J.merge({
      
      selector: '__no-valid-selector__',
      plugins: {} 
    
    }, options || {});
   
    // register at J.modules
    return J.modules[name] = {
      name: name,
      init: function() {
        
        sandbox = {
          dom: $(options.selector)
        };
      
        var reveal = module_init(sandbox) || {};
        
        for(var key in this.plugins) {
          if(this.plugins.hasOwnProperty(key) && typeof this.plugins[key] === 'function')
            J.merge(reveal, this.plugins[key](sandbox, reveal) || {});
        }
        
        return reveal;
                        
      },
      plugins: options.plugins
    };
  }
});



Module('Header', function(my) {

  my.settings = {};
  
  return {
    settings: my.settings
  };
  
}, {

  selector: '#header',
  plugins: {
  
    /**
     * @mixin treeview
     */
    treeview: function(my, reveal) {

      my.settings.treeview = {
        collapsed: true, 
        animated: 'fast',
        persist: 'cookie',
        cookieOptions: {
          path: '/'
        }
      };
      
      var apiTree = my.dom.find(".api-browser > ul");
      
      apiTree.treeview(my.settings.treeview);
    },
    
    /**
     * @mixin collapsible
     */
    collapsible: function(my, reveal) {

      // @section Filling private variables  

      my.settings.collapsible = {
        cookieId: 'header-collapsed'
      }

      var buttons = {
        show: my.dom.find('a.expand'),
        hide: my.dom.find('a.collapse')
      };  
      
      var settings = my.settings.collapsible;
      
      // @section Defining functions
      
      function collapse() {
        $.cookie(settings.cookieId, 'true', { path: '/' });
        my.dom.addClass('collapsed');
        buttons.hide.hide();
        buttons.show.show();
      }
      
      function uncollapse() {
        $.cookie(settings.cookieId, 'false', { path: '/' });
        my.dom.removeClass('collapsed');
        buttons.hide.show();
        buttons.show.hide();
      }
      
      // @section Event Attachment  
      
      buttons.hide.click(collapse);
      buttons.show.click(uncollapse);
      
      // @section Initialization
      
      if($.cookie(settings.cookieId) == 'true')
        collapse();
      
      else uncollapse();
      
      return {
        collapse: collapse,
        uncollapse: uncollapse
      };
    },
    
    apisearch: function(my, reveal) {
    
      // @section Filling private variables  
      
      my.settings.apisearch = {
        
      }
      
      var search_input = my.dom.find('input#search');
      
      // @section Attach events    
      
      search_input.bind('keyup change click', function() {
      
        if(search_input.val() == "")
          my.dom.removeClass("search");
      
        else
          my.dom.addClass("search");
      });
    
    }
  }
});

J.modules.Header.plugins.search = function(my, reveal) {

  console.log(my, reveal);

}


Module('Body', function(my) {
  
  var tooltip_ables = my.dom.find('.signature .params .param');
  tooltip_ables.tooltip();  

}, {
  selector: '#main > article',
  plugins: {
  
    source_code: function(my, reveal) {

      my.dom.find('h3.source').each(function(i, el) {
        
        var header = $(el).addClass('collapsed'),
            code = header.next('code').hide();
        
        header.toggle(function(){
          header.removeClass('collapsed');
          code.slideDown();
        }, function() {      
          code.slideUp(function() { header.addClass('collapsed'); });
        });
      }); 
    }  
  }
});


$(function() {    
  // initialize Modules
  for(var key in J.modules) {
    if(J.modules.hasOwnProperty(key))
      J.modules[key].init();
  }
});