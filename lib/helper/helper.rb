# ../data.img#1800236:1
require 'pathname'
require 'rdiscount'

require_relative 'linker'

module Helper

  module Helper
 
    include Linker
 
    def tag(sym, content = "", attrs = {})
      attributes = attrs.map{|k,v| "#{k}=\"#{v}\""}.join ' '
      "<#{sym.to_s} #{attributes}>#{content}</#{sym.to_s}>"
    end
   
    def signature(method)
      params = method.params.map{|p|p.name}.join(', ') unless method.params.nil?
      return_types = method.returns.first.types.join(', ') unless method.returns.nil? or method.returns.first.nil?
      "(#{return_types || 'Void'}) #{method.name}(#{params})"
    end
    
    def subsection(id, opts = {})
      unless opts[:collection].nil? or opts[:collection].size == 0
        "<h3>#{opts[:title]}</h3><ul class=\"#{id}\">" +       
        render(:partial => opts[:partial], :collection => opts[:collection]) +
        "</ul>"
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
        html += tag :link, "", :rel => 'stylesheet', :href => to_relative('css/'+path)
      end
      return html
    end
    
    def markdown(markdown_text)
      replace_links RDiscount.new(markdown_text).to_html
    end
    
    protected
    
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
  end
end
