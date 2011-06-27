class CodeObject::Object < CodeObject::Base
  token_reader :props, :prop
end

Token::Handler.register :object, :handler => :noop, :area => :none, :type => CodeObject::Object