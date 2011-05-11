/**
 * This function can be used like the following:
 * @example
 *   p = new Person("Peter Griffin");
 *
 * @constructor Person
 */
var Person = function(name) {

  this.name = name;

}; 
 
/**
 * Single argument version. Only supplies the function to which this object
 * acts as a prototype
 *
 * @prototype Person
 */
Person.prototype = {

  /**
   * Alerts a string containing the name of the person
   *
   * @function .sayHello
   */
  sayHello: function() {
      
    alert("Hello my name is " + this.name);
    
  }

};
