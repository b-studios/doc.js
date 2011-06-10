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
        
        J.merge(this, reveal);
        
        return this;
                        
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
        cookieId: 'header-collapsed',
        cookieSettings: {
          path: '/'
        }
      }

      var buttons = {
        show: my.dom.find('a.expand'),
        hide: my.dom.find('a.collapse')
      };  
      
      var settings = my.settings.collapsible;
      
      // @section Defining functions
      
      function collapse() {
        $.cookie(settings.cookieId, 'true', settings.cookieSettings);
        my.dom.addClass('collapsed');
        buttons.hide.hide();
        buttons.show.show();
      }
      
      function uncollapse() {
        $.cookie(settings.cookieId, 'false', settings.cookieSettings);
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
     
      my.apisearch = {
        data: J.data.apisearch
      };
      
      my.settings.apisearch = {
        
      }      
      
      var search_input = my.dom.find('input#search'),
          function_list = $('<ul>'),
          object_list = $('<ul>');
      
      
      
      function createObject(data) {
      
        var el = $('<li>', {              
                  // forward click to first a
                  click: function() {
                    window.location.href = $(this).find('a:first').attr('href');
                    return false;
                  }        
                })
                .hide()
                .data(data)        
                .append($('<a>', {
                  href: J.root + data.path,
                  html: data.name
                }));
        
        
        if(data.namespace != '') {
          el.append($('<span>', {
            html: ' (' + data.namespace + ')',
            'class': 'namespace'
          }));          
        }        
        return el;
      }
      
      
      // returns an { included: [], excluded: [] }
      function filter(list, filterString) {        
      
        var included = [],
            excluded = [];
      
        try {
          var regexp = RegExp(filterString, 'i');
          
          $.each(list, function(i, el) {
            // maybe to slow - check for performance improvements later on
            if(regexp.test($(el).data('fullname')))
              included.push(el)
            else
              excluded.push(el)
          });
        } catch(e) {
          included = list;
        }    
        
        return {
          included: included,
          excluded: excluded
        };
      }
      
      // shuffles the two lists, like two stacks of cards and invokes callback on each element.
      // the cards are delayed with timer ms.
      function shuffle(list1, list2, timer, callback) {
      
        var args = arguments;
      
        if(list1.length > list2.length)
          callback(list1.shift());
        
        else if(list2.length > 0)
          callback(list2.shift());
          
        else if(list1.length > 0)
          callback(list1.shift());
        
        else return;
          
        setTimeout(function() {
          shuffle.apply(this, args);
        }, timer);  
      }
          
      // @section Attach events
      
      search_input.bind('keyup change click', function() {
        
        var val = search_input.val();            
      
        if(search_input.val() == "") {
          my.dom.removeClass('search');
      
        } else {
          my.dom.addClass('search');
          
          var filtered_functions = filter(function_list.children(), val);          
          var filtered_objects = filter(object_list.children(), val);  
     
          $(filtered_functions.included).removeClass('last').last().addClass('last');
          $(filtered_objects.included).removeClass('last').last().addClass('last');  
     
          shuffle(filtered_functions.included, filtered_objects.included, 5, function(el) {
            el = $(el);
            if(!el.is(':visible'))
              el.css({opacity: 1}).slideDown();                       
          });

          shuffle(filtered_functions.excluded, filtered_objects.excluded, 5, function(el) {
            el = $(el);
            if(el.is(':visible'))
              $(el).css({opacity: 0.5}).slideUp();
          });
        }
      });
      
      search_input.keydown(function(evt) {
         
        switch(evt.keyCode) { 
        
        case 27:        
          $(this).val('').trigger('change');
        
        case 13:
          return false;
        }         
      });
      
      // @section Initialize
    
      
      // On initialization create all elements and then filter them     
      $.each(my.apisearch.data.functions, function(i, el) { 
        function_list.append(createObject(el));
      });
      $.each(my.apisearch.data.objects, function(i, el) {
        object_list.append(createObject(el));
      });
      
      my.dom.find('.functions').append(function_list);
      my.dom.find('.objects').append(object_list);      
    }
  }
});


Module('Body', function(my) {
  
  var tooltip_ables = my.dom.find('.signature .params .param');
  tooltip_ables.tooltip();  

}, {
  selector: '#main > article',
  plugins: {
  
    source_code: function(my, reveal) {
            
      // apply syntax highlighting
      SyntaxHighlighter.config.tagName = "code";      
      SyntaxHighlighter.defaults.toolbar = false;
                        
      // replace all sources
      my.dom.find('h3.source').each(function(i, el) {
        
        var header = $(el).addClass('collapsed'),
            code = header.next('code');
       
        SyntaxHighlighter.highlight(code.get(), {}, function(el) {
          
          var code = $(el).hide();
        
          header.toggle(function(){
          header.removeClass('collapsed');
            code.slideDown();
          }, function() {      
            code.slideUp(function() { header.addClass('collapsed'); });
          });
        
        });
      });
      
      
      // replace all code-examples
      my.dom.find('code.example').each(function(i, el) {      
        SyntaxHighlighter.highlight([el], {
          gutter: false
        }, function(el) {
          $(el).find('.syntaxhighlighter').addClass('example');
        });      
      });
      
    }
  }
});


$(function() {    
  // initialize Modules on Page-load
  for(var key in J.modules) {
    if(J.modules.hasOwnProperty(key))
      J.modules[key].init();
  }
});
