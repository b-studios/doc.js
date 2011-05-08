# ../data.img#1858561:1
require_relative 'base'
require_relative 'type'

module CodeObject

  class Object < CodeObject::Base
    
    token_reader :props, :prop
    
  end
    
end

CodeObject::Type.register :object, CodeObject::Object

Token::Handler.register :object, &Token::NOOP
Token::Handler.register :prop, :typed_with_name
