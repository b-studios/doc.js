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
      params = method.params.map { |p|
        "<span class=\"param\">#{p.name}</span>" +
        "<span class=\"tooltip\">(<span class=\"types\">#{p.types.map{|t| link_to(t) }.join(', ')}</span>) " +
        "#{replace_links p.content}</span>"
      }.join(', ') unless method.params.nil?
      
      return_types = method.returns.first.types.map{|type| link_to(type) }.join(', ') unless method.returns.nil? or method.returns.first.nil?
      "(#{return_types || 'Void'}) <span class='name'>#{method.name}</span>(<span class='params'>#{params}</span>)"
    end
    
    def subsection(id, opts = {})
      unless opts[:collection].nil? or opts[:collection].size == 0
        "<h3>#{opts[:title]}</h3><ul class=\"#{id} subsection\">" +       
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
    
    def to_html(markdown_text)
      replace_links RDiscount.new(markdown_text).to_html
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
    
    def print_hierarchy(object) 
      children = object.children.reject {|c| c.is_a? CodeObject::Function }.values
      parents = object.parents
      
      parents.map {|parent| "<ul><li>#{link_to parent, parent.name}" }.join('') +
      "<ul><li class=\"this\">#{link_to object, object.name}<ul class=\"children\">" +
        children.map {|child| "<li>#{link_to child, child.name}</li>" }.join('') +
      "</ul>" * (parents.size + 2)
    end
  end
end
