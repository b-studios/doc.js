# This Helper-methods are template-specific ones. If you are using your own template, you might not 
# need them anymore
# They are included in the Typed-RenderTask 
module Helper::Template

  # Creates the html-signature of a function, including the markup for a tooltip
  def signature(method_or_token)
  
    if method_or_token.is_a? Token::Token
      params = method_or_token.children.select {|t| t.token == :param }
      returns = method_or_token.children.select {|t| t.token == :return }
    else
      params = method_or_token.params
      returns = method_or_token.returns
    end
  
  
    params = params.map { |p|
      "<span class=\"param\">#{p.name}</span>" +
      "<span class=\"tooltip\">(<span class=\"types\">#{p.types.map{|t| link_to(t) }.join(', ')}</span>) " +
      "#{replace_links p.content}</span>"
    }.join(', ') unless params.nil?
    
    return_types = returns.first.types.map{|type| link_to(type) }.join(', ') unless returns.nil? or returns.first.nil?
    "(#{return_types || 'Void'}) <span class='name'>#{method_or_token.name}</span>(<span class='params'>#{params}</span>)"
  end
  
  
  # Creates an hierarchy-overview, which can be seen in the sidebar. The direct parent and
  # all children are listed in the overview:
  # 
  #     DocJs
  #       > CurrentNode
  #           ChildNode1
  #           ChildNode2
  #           ...
  #
  def hierarchy(object) 
    
    children = object.children.values.reject {|c| c.is_a? CodeObject::Function }
    parents = object.parents
    
    parents.map {|parent| "<ul><li>#{link_to parent, parent.name}" }.join('') +
    "<ul><li class=\"this\">#{link_to object, object.name}<ul class=\"children\">" +
      children.map {|child| "<li>#{link_to child}</li>" }.join('') +
    "</ul>" * (parents.size + 2)
  end
  
  # Creates the markup for the Api-Tree Browser in the heading-section. The JavaScript tree is 
  # powered by jquery-treeview by Jörn Zaefferer
  #
  # @example output
  #  <ul>
  #   <li class="object"><a href="api/Core.html"><span>Core</span></a>
  #     <ul>
  #       <li class="function"><a href="api/Core/extend.html"><span>extend</span></a>
  #       <li class="function"><a href="api/Core/extensions.html"><span>extensions</span></a>
  #     </ul>
  #  </ul>
  #
  # @see http://bassistance.de/jquery-plugins/jquery-plugin-treeview/
  # @see http://docs.jquery.com/Plugins/Treeview
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