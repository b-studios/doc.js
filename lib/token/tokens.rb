module Token::Handler

  register :author, :area => :sidebar
  register :public, :area => :sidebar
  register :private, :area => :sidebar
  register :version, :area => :sidebar
  
  register :see, :area => :footer

  register :deprecated, :area => :notification  
  register :todo, :area => :notification
  register :example, :template => 'examples', :handler => :named_multiline
  
  register :overload, :area => :none do |token, content|
  
  
  end
  
end
