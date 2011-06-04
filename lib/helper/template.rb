module Helper

  module Template
  
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
    
    def hierarchy(object) 
      children = object.children.values.reject {|c| c.is_a? CodeObject::Function }
      parents = object.parents
      
      parents.map {|parent| "<ul><li>#{link_to parent, parent.name}" }.join('') +
      "<ul><li class=\"this\">#{link_to object, object.name}<ul class=\"children\">" +
        children.map {|child| "<li>#{link_to child}</li>" }.join('') +
      "</ul>" * (parents.size + 2)
    end
    
    def api_browser(root = Dom.root)
     
      if root == Dom.root
        output = ""
      elsif root.is_a? Dom::NoDoc
        output = "<li class=\"nodoc\"><span>#{root.name}</span>"
      elsif root.is_a? CodeObject::Function
        output = "<li class=\"function\">" + link_to(root, tag(:span, root.name))
      else # Object
        output = "<li class=\"object\">" + link_to(root, tag(:span, root.name))
      end
      
      if root.has_children?        
        output += "<ul>"
        root.children.values.each do |child|
          output += api_browser(child)
        end
        output += "</ul>"
      end
      
      return output
    end
  
  end
  
end