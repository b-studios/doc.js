module Token::Handler

  register :author, :area => :sidebar
  register :public, :area => :sidebar
  register :private, :area => :sidebar
  register :version, :area => :sidebar
  
  register :see

  register :deprecated, :area => :notification  
  register :todo, :handler => :named_multiline, :area => :notification
  register :example, :handler => :named_multiline
  
  register :overload do |token, content|
  
  
  end
  
end
