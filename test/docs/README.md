Beautiful, flexible JavaScript Documentation
============================================
Doc.js automatically creates beautiful documentation from your JavaScript-Source. 

Features
--------
- One command to install
- Use markdown in your documentation
- Easy to customize (Create your own DSL in a sec!)
- Nice and clean default template
- Integrates well with your existing deployment
- For ruby lovers - it's written in ruby

Installation
------------
If you have Ruby 1.9 and rubygems installed you only need to type

    gem install docjs

That's Your Part
----------------
Because Doc.js basically is language unaware, you have to tell it what to do. This example shows how 
your documentation could look like

    /**
     * @function medianight.create_poster
     *
     * This function creates a poster, which can be used at the MediaNight
     * @param [String] term Something like "SS2011"
     * @param [Numeric] dpi The target-resolution of the poster
     * @return [Poster] The finished poster
     */
     medianight.create_poster = function(term, dpi) {
        ...
     }
