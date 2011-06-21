Configuration Options
=====================
You can run Doc.js with your custom configuration by either adding the desired
options as command-line parameter or by writing them in a configuration-file.
All available options are listed if you type:

    docjs help docjs

For example one may run docjs using only command-line options

    docjs --files="js/*.js" --output="out" --appname="My Documentation"

The same options, could be written in a config-file `docjs.yml`

    files: 
    - js/*.js
    
    output: out
    appname: My Documentation
    
Then simply run:

    docjs docjs.yml


**TODO: describe docjs configure **


List of Config-options
----------------------

| Option       | Default    | Usage            
|--------------|------------|------------------
| `appname`    | MyAppName  |
| `docs`       | README.md  | List of Markdown-documents. You can use wildcards like `docs/**/*.md`
| `files`      | ---        |                  
| `logfile`    | ---        |                  
| `loglevel`   | info       |
| `output`     | out        |
| `templates`  | *internal* |


Note
----
Commandline lists like `docs` and `files` are whitespace separated.

    --files="first_file.js" "others/*.js"
    
In a configuration file, you can use a simple yml-list:

    files: 
    - first_file.js
    - others/*.js
     

Available Tokens
================

@author
-------

@constructor
------------

@deprecated 
-----------

@event
------

@example
--------

@function
---------

@method
-------

@note
-----

@object
-------

@overload
---------

@param
------

@private
--------

@prop
-----

@prototype
----------

@public
-------

@return
-------

@see
----

@throws
-------

@todo
-----

@version
--------

@warn
-----


