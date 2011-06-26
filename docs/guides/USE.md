Configuration Options
=====================
You can run Doc.js with your custom configuration by either adding the desired
options as **command-line** parameter or by writing them in a **configuration**-file.
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

**Please note that all paths you specify will be resolved relative to the current working 
directory!**


List of Config-options
----------------------

| Option       | Default    | Usage            
|--------------|------------|-----------------------------------------------------------------------
| `appname`    | MyAppName  | The appname, which is stored in `Configs.options[:appname]` and can be used in the view-templates.
| `docs`       | README.md  | List of Markdown-documents. You can use wildcards like `docs/**/*.md`
| `files`      | ---        | List of JavaScript-Files. Just like the docs, you can use wildcards in the paths.
| `logfile`    | ---        | Use this path if you want the log-messages to be written to a file.       
| `loglevel`   | info       | All the messages lower then the specified level will not be printed. Available levels are (in that order): `debug`, `info`, `warn`, `error`
|              |            | 
| `output`     | out        | The generated documentation will be saved at this path. Please double-check it to prevent files to be overriden. 
| `templates`  | *internal* | If you used `scaffold` or created your own templates by hand, you have to specify this path to make docjs use them.


Note
----
Commandline lists like `docs` and `files` are whitespace separated.

    --files="first_file.js" "others/*.js"
    
In a configuration file, you can use a simple YAML-list:

    files: 
    - first_file.js
    - others/*.js


Types
=====
Types specify the `type` of the documented CodeObject. There are a only a few types available per 
default:

- `@object`
- `@function`
- `@prototype`
- (`@constructor`)

The first two are considered primitives of the JavaScript language. Advanced concepts like classes, 
mixins, pseudoclassical inheritence and so on can easily be added by 
{file:CUSTOMIZE.md creating your own template} or modifying the existing one. `@prototype` is added
as type, so you can see how to create your own custom-types. More information about the `@prototype`
- type can be found in {file:PATTERNS.md#Prototypal_Inheritance the documentation-pattern-list}.

Types classify the piece of code, you are documenting - so adding a type is essential and **always 
required**.

    /**
     * @function sayHello
     */

Creates a documentation-element named `sayHello` with the type {CodeObject::Function}.

Namespacing
===========
Because writing documentation takes enough time, there is a shorthand to express namespaces 
**relative** to the parent in the surrounding scope. 

    /**
     * @object some.namespace
     */
    var some.namespace = {
      
      /**
       * @function some.namespace.sayHello
       */
       sayHello: function() {...}
    }

can be rewritten as:

    /**
     * @object some.namespace
     */
    var some.namespace = {
      
      /**
       * @function .sayHello
       */
       sayHello: function() {...}
    }
    
This only works, because the JavaScript-Parser of Doc.js is working scope-aware. So you always can 
use the dot-notation if your comment is in the lexical-scope of the parent comment.

The dot-notation (`.sayHello`) was inspired by file-systems, where one dot refers to the current
directory. It also fit's into the JavaScript context, because the child can be accessed by using
the dot.

Please note: **If relative naming results in errors you still can use absolute naming**.

Available Tokens
================

@author
-------
| Handler          | Area       | Template
|:-----------------|:-----------|:-------------
| :default         | :sidebar   | :default

Can be used multiple times for many authors like:

    @author Jon Foo
    @author Peter Bar (Editor)
    

@constructor
------------
Simply creates a function-type and makes it answer `fun.constructor?` with `true`.


@deprecated 
-----------
| Handler          | Area           | Template
|:-----------------|:---------------|:-------------
| :default         | :notification  | :default

@event
------
| Handler                  | Area    | Template
|:-------------------------|:--------|:-------------
| :named_nested_shorthand  | :body   | :default

@example
--------
| Handler          | Area   | Template
|:-----------------|:-------|:-------------
| :named_multiline | :body  | :example

@function
---------
Type


@method
-------
Type

@note
-----
| Handler          | Area           | Template
|:-----------------|:---------------|:-------------
| :default         | :notification  | :default

@object
-------
Using @object set's the type of the documented CodeObject to {CodeObject::Object}. No token will be
added. See {file:USE.md#Types types} for further information about the types in Doc.js.

@overload
---------
| Handler      | Area   | Template
|:-------------|:-------|:----------
| :custom      | :none  | :default

You can use overloads, if your **function requires multiple signatures**.
So instead of adding your `@param`'s and `@return`'s directly to the function's documentation you 
specify overloads like:

    /**
     * @function non.sense
     *
     * @overload
     *   Your description of this overload. Every line, not starting with `@` or intended by  2 
     *   spaces (Which indicate linecontinuation) is treated as documentation for the overload.
     *   
     *   @param [String] name your name. We can continuate this line, by simply intending it
     *     two spaces. You see? Simple, hu?
     *   @param [Array<String>] collegues Your coworkers
     *   @return [Void] Returns nothing!
     *
     * @overload
     *   This is another way to use this function. It only requires one parameter.
     *   @param [Object] person 
     *   @return [String] The name of the person
     */
     
Please note, that in line 7 of this example the continuation of @overload is achieved due intending
the empty line with some spaces.


@param
------

@private
--------
| Handler          | Area       | Template
|:-----------------|:-----------|:-------------
| :default         | :sidebar   | :default

@prop
-----

@prototype
----------

@public
-------
| Handler          | Area       | Template
|:-----------------|:-----------|:-------------
| :default         | :sidebar   | :default

@return
-------

@see
----

@throws
-------

@todo
-----
| Handler          | Area           | Template
|:-----------------|:---------------|:-------------
| :default         | :notification  | :default

@version
--------
| Handler          | Area       | Template
|:-----------------|:-----------|:-------------
| :default         | :sidebar   | :default

@warn
-----
| Handler          | Area           | Template
|:-----------------|:---------------|:-------------
| :default         | :notification  | :default
