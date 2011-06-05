# ../data.img#1800236:1
require 'pathname'
require 'rdiscount'

require_relative 'linker'
require_relative 'template'

module Helper

  module Helper
 
    include Linker
    include Template
 
    def tag(sym, content = "", attrs = {})
      attributes = attrs.map{|k,v| "#{k}=\"#{v}\""}.join ' '
      "<#{sym.to_s} #{attributes}>#{content}</#{sym.to_s}>"
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
    
    def code(source)
    
      # find minimal intendation
      intendation = source.lines.map {|line| line.match(/(^\s+)/) && line.match(/(^\s+)/).captures.first.size || 0 }.min
      
      # @todo there has to be a better way for that      
      tag :code, source.lines.map { |line| line[intendation .. line.size] }.join(""), :class => 'block'
    end
    
    def to_html(markdown_text, *markdown_opts)
      replace_links RDiscount.new(markdown_text, *markdown_opts).to_html
    end
    
    def toc(markdown_text)
      RDiscount.new(markdown_text, :generate_toc).toc_content
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
    
      rendered = ""
    
      token_groups = code_object.tokens.values.each do |tokens|        
        # tokens is an array of Token::Token
        if not tokens.empty? and tokens.first.area == area
        
          template = tokens.first.template
        
          rendered += render :partial => "tokens/#{template}", :locals => { :tokens => tokens }
        end
      end            
      
      rendered
    end
    
  end
end
