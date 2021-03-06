Doc.js
======
Bad news first: **You still have to write documentation**

Good news: **It will look awesome!!**

Doc.js is a JavaScript-Documentation tool which detects `tokens` in your comments and generates 
documentation out of it. Doc.js could be ported pretty easy to any other language, because the most 
of it's parts are language agnostic.

Demo Projects
-------------
- [arrayJS](http://b-studios.github.com/arrayJS/)

Features
--------
- One command to install
- Use markdown in your documentation
- Easy to customize (Create your own DSL in a sec!)
- Nice and clean default template
- Integrates well with your existing deployment
- For ruby lovers - it's written in ruby

Guides
------
If you read this, you may belong to one of the following groups:

1. You want to {file:TRY.md try out Doc.js} for the first time
2. You need some more {file:USE.md information, how to use Doc.js}
3. You want to {file:CUSTOMIZE.md customize Doc.js}, to exactly fit your needs

Useful Information
------------------
- List of supported {file:USE.md#Available_Tokens Tokens}
- Built in {Token::Handler Handlers}
- Overview about {Generator::Generator Generators}


Supported Ruby-Version
----------------------
Currently **only ruby > 1.9.x is supported**. Support for 1.8.x is not planned, because there are 
some problems:

- UTF-8 Support in parser
- Intensive use of require_relative
- Named captures in RegularExpressions

For the last two, a rewrite could solve the compatibility issues. Sadly enough currently i don't 
find the time to fix thoses and the first problem in 1.8.x so only 1.9+ is supported. If you have 
the time to work on 1.8 compatibility you would make me (and possibly some other 1.8 users) very 
happy.

Architectural Insides
---------------------
{DocJs} is a good starting point if you want to get started with information about the structure of DocJs.

Installation
------------
    gem install docjs    

Dependencies
------------
The following Gems are required to make docjs work and should automatically be installed while 
installing docjs:

- thor
- rdiscount


Legal Notice & Contact
----------------------
docjs is released under MIT-License. See LICENSE.md for more information.
The used icons, are part of the legendary [famfamfam-silk-iconset](http://www.famfamfam.com/lab/icons/silk/).
The font used in title and headlines is a Google-Webfont called `TerminalDosis-Light`.

For further information about contacting me, please visit my personal [blog](http://b-studios.de).
Of course you are also invited to [follow me on twitter](http://twitter.com/#!/__protected).
