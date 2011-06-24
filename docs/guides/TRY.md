Installation
============
Prerequisites: You need Ruby >= 1.9 to run Doc.js

    gem install docjs  

After installing the gem, you can start by typing `docjs` in your console. This
will bring up a small introduction and an overview of all available commands. 
To retreive some more information about one specific command simply type 

    docjs help COMMAND_NAME


Basic Usage
===========

Configuration
-------------
Before you can use Doc.js you may create your own **Configuration-File**. This 
can easily be done, using the built-in configuration-generator:

    docjs configure
    
You optionally can specify the filename of your configuration file. If no file 
is specified the configs will be written to `docjs.yml`.

    docjs configure my_config_file.yml

The configuration is an interactive one - simply answer the questions you will 
be asked.


Start documenting your code
---------------------------
To make jsdoc recognize your documentation you have to use some special tokens.
Let's write a documented function `hello_doc`:
    
    /**
     * @function hello_doc
     *
     * Innovative function to greet a Person.
     *
     * @param [String] name the person you want to greet
     * @return void
     */
    function hello_doc(name) {
      console.log("Hello " + name + "!");
    }
    
The symbols `@function`, `@param` and `@return` are called **tokens** in Doc.js. 
There are many more by default. To see which one you can use simply type:

    docjs tokens
  

Run the documentation and enjoy!
--------------------------------
Now it's time to kickoff the documentation-process by typing:

    docjs your_config.yml

You will find the docs in the output-directory you have specified in your 
config-file.
