/**
 * 
 * Man könnte überlegen den Extensions ein Sandbox-Element zu geben, welches diese auch erweitern
 * können. z.B. könnte damit die Hooks-extension die Sandbox erweitern, ohne dass diese von modulen
 * erreichbar wären.
 *
 * Core contains a simple {Core.logger logger} which only supports one functionality {.log}.
 *
 * @todo Extensions als Packages: Core.extend('foo.bar') => Core.foo.bar mit foo = foo|| {}
 * @todo Dependency Check der Extensions
 * @todo Extensionloader
 *
 * @object Core
 */
var Core = Core || (function(){
 
  var _extensions = {};
  
  var core = {

    /**
     * register new {Core.extensions}
     * 
     * @function Core.extend
     *
     * @param [String] id the id to register the new {Core.extensionss extension} under
     * @param [Function] constructor a callback function, which acts as
     *   constructor
     *
     * @return [Core.extensions] the constructed extension
     */
    extend: function(id, constructor) {
      
      // Already defined
      if(!!core[id]) {
        core.logger.log("Info: Overwriting '"+id+"'. It is already defined.");
      }
      
      var ext = constructor();
      if(!!ext) {
        core[id] = ext;
        _extensions[id] = ext;
      } else {
        core.logger.log("Info: Constructor of '"+id+"' did not return a valid value.");
      }
    }, 
    
    /**
     * List all registered {Core.extensions extensions}
     *
     * @function Core.extensions
     *
     * @return [Array] all registered extensions
     */
    extensions: function() {
      return _extensions;
    },    
    
    /**
     * Adds minimal logging functionality to {Core}
     *
     * @object Core.logger
     */
    logger: {
    
      /**
       * Logs a message if the console is present
       *
       * @function Core.logger.log
       * @param [String] msg The message to log
       */
      log: function(msg) {
        if(!!window.console) {
          window.console.log(msg);
        }
      }
    },
    
    /**
     * Config Object for Core
     * @object Core.properties
     *
     * @prop [Boolean] logging turns internal logging on and off
     * @prop [Numeric] maximalExtensions limits the maximum extensions count
     * @prop [Boolean] autostart should Core start on Application-start?
     */
    properties: {
      logging: true,
      maximalExtensions: 4,
      autostart: true
    }
  };

  return core;      
})();