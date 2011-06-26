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


# We want to support either named-typed-tokens like
#  @param [Foo] barname some description
#
# or multiline tokens like:
#  @param configs
#    Some configuration Object with following properties:
#    [String] foo some string
#    [Bar] bar and another one
#
# @note this can also be utilized for JavaScript-Event-Triggers or Callbacks with Parameters
Token::Handler.register :param, 
          :area => :none, 
          :description => "Token for Function-Parameters like '@param [String] name your name'" do |tokenklass, content|

  # it's @param [String] name some content
  if content.lines.first.match Token::Handler::TOKEN_W_TYPE_NAME
    self.add_token Token::Handler.apply(:typed_with_name, Token::Token::ParamToken, content)
  
  # it maybe a multiline
  else
    self.add_token Token::Handler.apply(:named_nested_shorthand, Token::Token::ParamToken, content)
  end   
end


Token::Handler.register :return, :handler => :typed, :area => :none, :description => "Returnvalue of a Function"
Token::Handler.register :throws, :handler => :typed

# MethodAlias
Token::Handler.register :method, :handler => :noop, :area => :none, :type => CodeObject::Function

# ConstructorAlias
Token::Handler.register(:constructor, :type => CodeObject::Function) { |token, content| @constructor = true }