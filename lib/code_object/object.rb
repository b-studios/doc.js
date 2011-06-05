# ../data.img#1858561:1
require_relative 'base'
require_relative 'type'

module CodeObject

  class Object < CodeObject::Base
    
    token_reader :props, :prop
    
  end
    
end

CodeObject::Type.register :object, CodeObject::Object
Token::Handler.register :object, :handler => :noop

Token::Handler.register :prop, :handler => :typed_with_name
