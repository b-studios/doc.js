class CodeObject::Function < CodeObject::Object
 
  token_reader :params, :param
  token_reader :returns, :return

  def constructor?
    @constructor || false
  end
  
  # @todo i need a @prototype token in object
  def prototype
    children[:prototype]
  end

  def display_name
    @name + '()'
  end
  
end 

Token::Handler.register :function, 
         :handler => :noop, 
         :area => :none,
         :type => CodeObject::Function,         
         :description => "Type-Token to categorize all kind of JavaScript-Functions"