Concept of the Documententation
===============================

There are only two build-in types, we want to pay attention to:

  1. Objects
  2. Functions
  
  
Object
------
By **Objects** we mean all kind of *things*, that can contain other things. Those containted ones, we call **properties** of the Object.

In JavaScript this may look like:

    var obj = {
      property_one: function() { ... },
      property_two: {
        // another object
      },
      property_three: 3
    }


Function
--------
**Functions** are *things*, that can be executed. They can have **parameters** and **return-values** There are two types of Functions: plain functions and **constructors**.

Example for a plain function:

    function my_func(param) {
      return "Hello world!";
    }

Example for a function as a constructor

    function my_constructor() {
      this.message = "Hello world!";    
    }


  Remember: any return-value of a constructor-function will be ignored and replaced by this

But a function can be an object at the same time. For example:

    function my_func_two() {
      return "fancy function";    
    }
    my_func_two.message = "Say hello to Mr. Foo";

Most important a function can contain one special property **prototype**.

  Remember: In this case the function has to be a constructor. Otherwise prototype would be useless, because it is only used when creating instances of the function using new. After creating an instance the prototype-object is accessible in the this-context of the instance.

    function my_constructor() {
      this.message = "Hello world!";    
    }
    my_constructor.prop1 = 456;
    my_constructor.prototype = {
      some_proto_prop: 123
    }

Revealing Module Pattern
------------------------
But what about revealing modules?

    function my_module() {

      // some private stuff here

      return {
        property_of_the: "returned object"
      };    
    }

One should pay attention to this pattern while creating a documentation tool.

Conclusion
----------
So we can break it down to Functions and Objects. Objects can have properties. Functions can, at the same time, be Objects. There are special functions, called *constructors*, which in turn have one special property called *prototype*. This property has to be handled special in documentation.
