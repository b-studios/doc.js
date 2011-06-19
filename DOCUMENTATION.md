Fullqualifier
-------------
Like an absolute path (/etc/init.d/apache2) we use `FOO.bar` as fullqualifier to
an object or function.

A leading dot suggests filling the empty leading space with the current parsing-context. 
As such `.something_else` would be resolved to `FOO.bar.something_else` in the current context.

Examplecode:

    /**
     * @function my_module
     * @return [my_module.object]
     */
    function my_module() {

      // some private stuff here
      
      
      /** 
       * @property .foo
       */
      my_module.foo = 123;


      /** 
       * @property .foo_bar
       */
      my_module.foo_bar = 789;
      

      /**
       * @object .object
       */
      return {
        /* @property .object.property_of_the */
        property_of_the: "returned object"
      };    
    }
