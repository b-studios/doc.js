/**
 * 
 * Man könnte überlegen den Extensions ein Sandbox-Element zu geben, welches diese auch erweitern
 * können. z.B. könnte damit die Hooks-extension die Sandbox erweitern, ohne dass diese von modulen
 * erreichbar wären.
 *
 * Noch eine Überschrift
 * =====================
 * Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt 
 * ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo 
 * dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor 
 * sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor
 * invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et 
 * 
 *     if(!!core[id]) {
 *       core.logger.log("Info: Overwriting '"+id+"'. It is already defined.");
 *     }
 *
 *
 * Justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum 
 * dolor sit amet.
 * 
 * Testüberschrift
 * ---------------
 * Dies ist nur ein Absatz in **Markdown**, um zu testen, ob dies funnktioniert.
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
     * @example Testextension
     *   Core.extend('testextension', function() {
     *     return {};
     *   });
     *
     *
     * @param [String] id the id to register the new {Core.extensionss extension} under
     * @param [Function] constructor a callback function, which acts as
     *   constructor for {Core.extensions}
     * @param settings
     *   [String] name the name of the extension
     *   [Number] pos the position to put the extension to (Defaults to 0)
     *   [String] color the background-color of the extension
     *
     * @return [Core.logger] the constructed extension
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
       *
       * @overload log(msg)
       *   @param [String] msg The message to log
       *
       * @overload log(level, msg)
       *
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
