module Token::Handler

  register :todo
  register :public
  register :private
  register :example do |token, content|
    rows = content.split(/\n/)
  
    # use first row as name
    name = rows.shift.strip
    code = rows.join("\n")
  
    add_token(token, NamedToken.new(name, code))
  end
end
