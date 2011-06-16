# ../data.img#1800236:1
require 'pathname'
require 'rdiscount'
require 'cgi'

require_relative 'linker'

# The Helpers are 'mixed' into your {Tasks::RenderTask} and therefore can be used in all 
# template-views.
# If you are searching for a method and don't know, where it may be implemented i suggest the 
# following inheritence chain as your search-strategy:
#
#     Helper::IncludedHelpers → Tasks::YourTask → Tasks::RenderTask → Renderer
#
# Somewhere at that chain you will find your desired function.
module Helper

  # The Helper-methods in this module are globally used one and should not depend on the template
  # you are using. You will find many html-helpers around here.
  module Helper
 
    include Linker
    
    def tag(sym, content = "", attrs = {})
   
      # @todo FIXME
      if block_given?
        _erbout << "<#{sym.to_s} #{attributize(content)}>"        
        content = yield
        _erbout << "</#{sym.to_s}>"
      else
        "<#{sym.to_s} #{attributize(attrs)}>#{content}</#{sym.to_s}>"        
      end     
    end    
    
    def truncate(string, num = 150)
      if string.length > num
        string[0..num] + " &hellip;"
      else
        string
      end
    end
    
    def style(*args)
      html = ""
      args.each do |path|
        html += tag :link, "", :rel => 'stylesheet', :href => to_relative('css/'+path+'.css')
      end
      return html
    end
    
    def script(*args)
      html = ""
      args.each do |path|
        html += tag :script, "", :src => to_relative('js/'+path+'.js')
      end
      return html
    end
    
    def code(source, opts = {})

      # defaults
      opts[:firstline] ||=  1
      opts[:class]     ||= "block"
          
      # find minimal intendation
      intendation = source.lines.map {|line| line.match(/(^\s+)/) && line.match(/(^\s+)/).captures.first.size || 0 }.min
      
      # @todo there has to be a better way for that      
      tag :code, h(source.lines.map { |line| line[intendation .. line.size] }.join("")), :class => "#{opts[:class]} brush:js first-line:#{opts[:firstline]}" 
    end
    
    def to_html(markdown_text, *markdown_opts)
      replace_links RDiscount.new(markdown_text, *markdown_opts).to_html
    end
    
    def toc(markdown_text)
      RDiscount.new(markdown_text, :generate_toc).toc_content
    end
    
    def h(to_escape)
      CGI.escapeHTML(to_escape)
    end
    
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
    
    def attributize(hash)
      hash.map{|k,v| "#{k}=\"#{v}\""}.join ' '
    end
    
  end
end
