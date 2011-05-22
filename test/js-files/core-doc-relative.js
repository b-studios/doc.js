/**
 * 
 * Man könnte überlegen den Extensions ein Sandbox-Element zu geben, welches diese auch erweitern
 * können. z.B. könnte damit die Hooks-extension die Sandbox erweitern, ohne dass diese von modulen
 * erreichbar wären.
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
     * register new {Core}-extension
     *
     * @function .extend
     *
     * @param [String] id the id to register the new extension under
     * @param [Function] constructor a callback function, which acts as
     *   constructor
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
     * List all registered {Core.extension extensions}
     *
     * @function .extensions
     *
     * @return [Array] all registered extensions
     */
    extensions: function() {
      return _extensions;
    },    
    
    /**
     * Adds minimal logging functionality to {Core}
     *
     * @object .logger
     */
    logger: {
    
      /**
       * Logs a message if the console is present. Can be extended with a custom {Core.extension}.
       *
       * @function .log
       * @param [String] msg The message to log
       */
      log: function(msg) {
        if(!!window.console) {
          window.console.log(msg);
        }
      }
    }
  };
  
  return core;      
})();
