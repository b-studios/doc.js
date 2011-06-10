Doc.js
======
Bad news first: **You still have to write documentation**

Good news: **It will look awesome!!**


Supported Ruby-Version
======================
Currently **only ruby > 1.9** is supported. I am working on supporting > 1.8.7, though this is not 
my target platform.


Installation
============
    gem install docjs    


Required Gems
=============
The following Gems are required to make docjs work and should automatically be 
installed while installing docjs:

  - thor
  - rdiscount
  

Basic Usage
===========

Configuration
-------------
Before you can use Doc.js you may create your own **Configuration-File**. This 
can easily be done, using the built-in 
configuration-generator:

    docjs configure
    
You optionally can specify the filename of your configuration file. If no file 
is specified the configs will be written to `build.yml`.

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


Legal Notice
============
docjs is released under MIT-License. See LICENSE.md for more information.
The used icons, are part of the legendary famfamfam-silk-iconset. (http://www.famfamfam.com/lab/icons/silk/)
