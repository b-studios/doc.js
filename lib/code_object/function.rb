# ../data.img#1858563:1
require_relative 'object'

module CodeObject

  class Function < CodeObject::Object
   
    token_reader :params, :param
    token_reader :returns, :return
  
    def constructor?
      !!self.token(:constructor)
    end
    
    # @todo i need a @prototype token in object
    def prototype
      children[:prototype]
    end  
  
  end 
  
end

CodeObject::Type.register :function, CodeObject::Function

Token::Handler.register :function, &Token::NOOP
Token::Handler.register :param, :typed_with_name
Token::Handler.register :return, :typed

# @constructor Foo.bar
CodeObject::Type.register :constructor, CodeObject::Function
Token::Handler.register :constructor
