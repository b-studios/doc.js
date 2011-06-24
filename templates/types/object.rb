module CodeObject

  class Object < CodeObject::Base
    
    token_reader :props, :prop
    
  end
    
end

Token::Handler.register :object, :handler => :noop, :area => :none
Token::Handler.register :prop, :handler => :typed_with_name