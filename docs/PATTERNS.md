Documentation Patterns
======================
There are some widely used patterns in JavaScript that need a proper way of documentation.

Prototypal Inheritance
----------------------
Because most of the times (this is my personal impression) prototypal inheritence is used like in 
the following example, Doc.js is specialized for that kind of prototyping.

    /**
     * @constructor Person
     * This is the constructor for a Person. Just like you and me.
     *
     * @param [String] name The name of the person
     * @param [Number] age
     */
    function Person(name, age) {
      this.name = name;
      this.age = age;
    }

    /**
     * @prototype Person
     */
    Person.prototype = {

      /**
       * @object .configs
       * @prop [Boolean] friendly
       */
      configs: {
        friendly: true
      },
      
      /**
       * @method .sayHello
       */
      sayHello: function() {
        if(this.friendly)
          console.log("Hello " + this.name);
          
        else console.log("Grmppfbra!");
      }

    }

Of course the usage of prototypes can easiliy be modified. For example to use prototype as a
property like

    /**
     * @constructor Collection
     * @prototype Array.prototype
     */
    function() {
      ...
    }

you have to delete the CodeObject::Prototype in `types/prototype.rb` and then register a token like

    register :prototype, :area => :none



Revealing Module Pattern
------------------------
The Revealing Module Pattern is a way of declaring some properties of an object as **private** and 
reveal only the public ones. This can be documented like the following:

     /**
      * @constructor Person
      * @param [String] name
      */
      function Person(name) {
      
      
        var methods = {
        
          /**
           * @method .eatPizza
           * @private
           */
          eatPizza: function() {
            ...mhh...
          }        
        }
      
        return {
        
          /**
           * @method .sayHello
           * Outputs a cheerfull greeting, containing the person's name
           */
          sayHello: function() {
            console.log("Hello, from " + name)
          }        
        };
     
      }
      
Ommiting the comment of the private function `eatPizza` would exclude it from the documentation. This
may be the disired way of documenting for example a API-Documentation.
