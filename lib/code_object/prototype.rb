# ../data.img#1858561:1
require_relative 'object'
require_relative 'type'

module CodeObject

  class Prototype < CodeObject::Object
    
    def initialize(*args)
      super(*args)
      @path += '.prototype'
    end
    
    # get the constructor, for which this prototype is used
    def constructor
      self.parent
    end
    
  end
    
end

CodeObject::Type.register :prototype, CodeObject::Prototype
Token::Handler.register :prototype, &Token::NOOP
