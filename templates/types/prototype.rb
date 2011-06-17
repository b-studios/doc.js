class CodeObject::Prototype < CodeObject::Object
  
  def initialize(*args)
    super(*args)
    @path += '.prototype'
  end
  
  # get the constructor, for which this prototype is used
  def constructor
    self.parent
  end
  
end

Token::Handler.register :prototype, :handler => :noop, :area => :none