require 'pathname'
require 'cgi'
require 'rdiscount'

require_relative 'linker'

# The Helpers are 'mixed' into your {Generator::Generator generator} and therefore can be used in 
# all template-views.
# If you are searching for a method and don't know, where it may be implemented i suggest the 
# following inheritence chain as your search-strategy:
#
#     Helper::IncludedHelpers -> Generator::YourGenerator -> Generator::Generator -> Renderer
#
# Somewhere at that chain you will find your desired function.
module Helper

  # The Helper-methods in this module are globally used one and should not depend on the template
  # you are using. You will find many html-helpers around here, that are inspired by rails.
  module Helper
 
    include Linker
    
    # Creates a HTML-Tag and adds the attributes, specified with `attrs`
    #
    # @todo FIXME - not working with block, yet...
    #   Rails incorporates a `capture` method, which captures the ERB-output of a block
    #   maybe we can use something like that
    #   `with_output_buffer` {http://apidock.com/rails/ActionView/Helpers/CaptureHelper/with_output_buffer}
    #
    # @example
    #    tag :a, 'Hello', :href => 'http://foobar.com', :class => 'red_one'
    #    #=> <a href="http://foobar.com" class="red_one">Hello</a>
    #
    # @param [Symbol, String] tagname
    # @param [String] content
    # @param [Hash<Symbol, String>] attrs
    # @return [String] html-tag
    #
    # @see #attributize
    def tag(tagname, content = "", attrs = {})
   
      # Not working with blocks!
      if block_given?
        _erbout << "<#{tagname.to_s} #{attributize(content)}>"        
        content = yield
        _erbout << "</#{tagname.to_s}>"
      else
        "<#{tagname.to_s} #{attributize(attrs)}>#{content}</#{tagname.to_s}>"        
      end     
    end    
    
    # Shortens the given string to the specified length and adds '...'
    def truncate(string, length = 150)
      string.length <= length ? string : string[0..length] + " &hellip;"
    end
    
    # Creates a css-link tag for each input string. The resource will be linked relativly.
    #
    # @example
    #   style 'foo', 'bar'
    #   #=> <link rel='stylesheet' href='../css/foo.css'/>
    #   #=> <link rel='stylesheet' href='../css/bar.css'/>
    #
    # @param [String] basename of the css-file (without extension)
    # @return [String] html-element to include the css-file
    def style(*args)
      args.map do |path|
        tag :link, "", :rel => 'stylesheet', :href => to_relative('css/'+path+'.css')
      end.join ''
    end
    
    # Creates a javascript-tag for each input string to import the script. The resource will be 
    # linked relativly.
    #
    # @example
    #   script 'foo', 'bar'
    #   #=> <script href='../js/foo.js'/>
    #   #=> <script href='../js/bar.js'/>
    #
    # @todo because those js-files are all relative links, they could be joined together and packed
    #   afterwards 
    #
    # @param [String] basename of the javascript-file (without extension)
    # @return [String] html-element to include the javascript-file
    def script(*args)
      args.map do |path|
        tag :script, "", :src => to_relative('js/'+path+'.js')
      end.join ''
    end
    
    # Removes intendation from the sources and generates a code-tag with all the required classes
    # to make the javascript-syntax-highlighter work.
    #
    # @example
    #   code "  function() {}"
    #   #=> <code class="brush:js first-line:1">function(){}</code>
    #
    # @example
    #   code "  function() {}", :firstline => 15
    #   #=> <code class="brush:js first-line:15">function(){}</code>
    #
    # @param [String] source
    # @param [Hash] opts
    # @option opts [Numeric] :firstline (1) The line-numeration will start with that number 
    # @option opts [String] :class ("block") A optional css-class which can be added
    #
    # @see http://alexgorbatchev.com/SyntaxHighlighter
    #
    # @return [String] the html-code-element 
    def code(source, opts = {})

      # defaults
      opts[:firstline] ||=  1
      opts[:class]     ||= "block"
          
      # find minimal intendation
      intendation = source.lines.map {|line| line.match(/(^\s+)/) && line.match(/(^\s+)/).captures.first.size || 0 }.min
      
      # @todo there has to be a better way for that      
      tag :code, h(source.lines.map { 
        |line| line[intendation .. line.size] 
      }.join("")), :class => "#{opts[:class]} brush:js first-line:#{opts[:firstline]}" 
    end
    
    # Escapes any html-elements in the given string
    #
    # @param [String] to_escape
    # @return [String] the escaped string
    def h(to_escape)
      CGI.escapeHTML(to_escape)
    end
    
    # Takes an absolute path and converts it to a relative one, comparing it to the **current
    # output path**.
    #
    # @param [String] path
    # @return [String] relative path
    def to_relative(path)
    
      path = Pathname.new(path)
      base = Pathname.new(@current_path)
      
      # for example /home/jsdoc/css/style.css
      # current: /home/jsdoc/output/Foo/Bar.html
      if not path.absolute?
        # resolve to Configs.output
        path = Pathname.new(Configs.output) + path
      end     
      
      Logger.debug "Relative path '#{path}' from '#{base}'"
      path.relative_path_from(base).to_s
    end    

    # To visually group the tokens you can specify an area. All tokens for one area (`:sidebar` in this
    # example) will be collected and can be rendered in the view-templates with the 
    # {Helper::Helper#render_tokens render_tokens} helper-method. 
    # 
    #     render_tokens :of => @code_object, :in => :sidebar
    #
    # While {Token::Handler.register registering a new token} you can use any symbol for `area`. But your tokens may not appear in 
    # the rendered html-documentation, unless you explicitly call `render_tokens` for each area.
    # 
    # The default-templates make use of the following areas:
    #
    # - :notification
    # - :body
    # - :sidebar
    # - :footnote
    #
    # If you don't want your token to be rendered at all, you can use `:none` as value for `area`.
    # 
    #     register :your_token, :area => :none
    #
    # @example render tokens of notification-area
    #   render_tokens :of => code_object, :in => :notification
    #
    # @example exclude `@deprecated`-Tokens from output
    #   render_tokens :of => code_object, :in => :body, :without => [:deprecated]
    #
    # @example use special default-template
    #   render_tokens :of => code_object, :in => :sidebar, :template => 'sidebar' 
    #
    # @param [Hash] opts
    # @option opts [CodeObject::Base] :of The object, which contains the tokens, to be rendered
    # @option opts [Symbol] :area The area to filter the tokens for
    # @option opts [Array<Symbol>, nil] :without Tokennames to be excluded from the output
    # @option opts [Symbol, String, nil] :template If you wan't to overwrite the default template
    #   you can use this option. (Note: templates, specified at token-registration have higher
    #   precedence, than this option)  
    def render_tokens(opts = {})
    
      code_object = opts[:of] or raise Exception.new("Parameter :of (CodeObject) required")
      area        = opts[:in] or raise Exception.new("Parameter :in (Area) required")
      exclude     = opts[:without] || []
    
      rendered = ""
    
      tokens = code_object.tokens.reject {|token, v| exclude.include? token }
    
      token_groups = tokens.values.each do |tokens|        
           
        # tokens is an array of Token::Token
        if not tokens.empty? and tokens.first.area == area
        
          template = tokens.first.template.to_s
          
          # overwriting default template with specified option[:template] if existant
          template = opts[:template].to_s if opts[:template] and template == 'default'
        
          rendered += render :partial => "tokens/#{template}", :locals => { :tokens => tokens }
        end
      end            
      
      rendered
    end
    
    # Takes a hash as input and returns a string, which can be included in a html tag.
    #
    # @example
    #   attributize :style => 'border: none;', :class => 'foo' #=> 'style="border: none;" class="foo"'
    #
    # @param [Hash] hash
    # @return [String]
    def attributize(hash)
      hash.map{|k,v| "#{k}=\"#{v}\""}.join ' '
    end
    
    # @group Markdown
    
    # Converts input text to html using RDiscount. Afterwards all contained links are resolved and
    # replaced.
    #
    # More information about the markdown_opts can be found at the
    # {http://rubydoc.info/github/rtomayko/rdiscount/master/RDiscount RDiscount-rdoc-page}.
    #
    # @param [String] markdown_text plain text with markdown-markup
    # @param [Symbol, nil] markdown_opts 
    # @return [String] converted html
    def to_html(markdown_text, *markdown_opts)
      replace_links RDiscount.new(markdown_text, *markdown_opts).to_html
    end
    
    # Can be used to generate a table of contents out of a markdown-text.
    # The generated toc contains links to the document-headlines.
    # To make this links actually work you need to process the document with the
    # :generate_toc flag, too.
    #
    # @example
    #   <%= toc(my_text) %>
    #   ...
    #   <%= to_html my_text, :generate_toc %>
    #
    # @param [String] markdown_text
    # @return [String] html table of contents
    def toc(markdown_text)
      RDiscount.new(markdown_text, :generate_toc).toc_content
    end
    
  end
end
