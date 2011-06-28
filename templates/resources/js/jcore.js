/*!
 * @object jCore
 * @version 1.0
 *
 * I gained much inspiration from Ext 4.0 and YUI. Also much Kudos to Nicolas
 * Zakas and Douglas Crockford for their amazing Books about the real JavaScript!
 *
 * If you like this, maybe you will like {http://code.google.com/p/joose-js/ joose} as well
 *
 * @prop [Number] version
 * @prop [Object] global Reference to the global namespace. Just in case we need it.
 */
var global = this;

var jCore = {
  version: 1.0,
  global: global
};

var J = J || jCore;

(function(J) {
  
  /**
   * @function jCore.merge
   *
   * Copies (or `merges`) all properties of extension to the original Object.
   *
   * @overload jCore.merge( original, extension )
   *   Single extension usage
   *   @param [Object] original The original Object you wan't to extend with new properties
   *   @param [Object] extension The Object, whose properties will be copied to `original`
   *
   * @overload jCore.merge( original, extension1, extension2, ... )
   *   Multiple extension usage   
   *   @param [Object] original The original Object you wan't to extend with new properties
   *   @param [Object, ...] extensions Each of the following options are interpreted as objects, 
   *     whose properties are copied to `original`
   * 
   * @example
   *   var foo = {
   *     bar: 4,
   *     baz: 'poo'
   *   }
   *   
   *   var foo2 = {
   *     bar: 5,
   *     boo: []
   *
   *   }
   *   
   *   jCore.merge(foo, foo2) //=> { bar: 5, baz: 'poo', boo: [] }
   */
  J.merge = function() {
    
      var original = Array.prototype.shift.apply(arguments);
          extensions = arguments;
    
      if(extensions.length == 0)
        return original;
        
      for(var i=0, len=extensions.length; i<len; i++) {
        for(var key in extensions[i]) {
          if(extensions[i].hasOwnProperty(key))
            original[key] = extensions[i][key];
        }  
      }
      return original;
    };
  
  /**
   * @function J.create
   *
   * @example
   *   J.create("Person", {
   *     constructor: function(name) {
   *       this.name = name;
   *     }, 
   *     say_name: function() { return this.name; }
   *   });
   *
   * @example Using revealing module pattern
   *   J.create("Person", {
   *     constructor: function(name) {
   *       return {
   *         say_name: function() { return name; }
   *       };
   *     }
   *   });
   *
   * @example Extending an object
   *   J.create("Student", Person
   *
   * Also mitigates the problem of using 'new' to create new instances. After 
   * creating the class Foo with creat, the following versions of instantiation 
   * are totally equivalent:
   *
   *     Foo("bar");
   *     new Foo("bar");
   *
   * @overload
   *   Creates a class called `path` and extends it with the given options
   *   
   *   @param [String] path
   *   @param options
   *     All options will be added as property to the object
   *     [Function] constructor The constructor of the class, which will be called, when
   *       instantiating a new object
   * 
   * @overload
   *   Creates a class `path`, that inherits from `parent` and will be extended with the given
   *   options
   *   
   *   @param [String] path
   *   @param [Object] parent
   *   @param [Hash] options (see other overload)
   */
  J.create = function(path, inherited, options) {   
    
    // implicitly inherits from Object.prototype
    if(arguments.length == 2) {
      options = inherited;
      inherited = Object;
    }
       
    var parts   = path.split('.'),
        name    = parts.pop(),
        context = global;
        
    for(var i=0, len=parts.length; i<len; i++) {
      var part = parts[i];
      context[part] = context[part] || {};
      context = context[part]; 
    }
    
    // We use a temporary object as prototype
    var F = function(){};
    F.prototype = inherited.prototype;
    
    // now we create our subclass and assign the prototype
    var Class = function() {};    
    Class.prototype = new F();
    
    // we introduce a second constructor to prevent the need for "new"
    var constructor = function() {    
      var instance = new Class();       
      if(options.hasOwnProperty('constructor') && typeof options.constructor === 'function')      
        return options.constructor.apply(instance, arguments) || instance;
        
      return instance;
    };
    
    // merge all options to prototype and override special values, if needed
    J.merge(Class.prototype, options, {
      constructor: constructor,
      superclass: inherited.prototype
    });    

    // save to specified context and return constructor
    context[name] = constructor;
    return constructor;
  };

})(jCore);