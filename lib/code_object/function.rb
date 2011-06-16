# ../data.img#1858563:1
require_relative 'object'

module CodeObject

  class Function < CodeObject::Object
   
    token_reader :params, :param
    token_reader :returns, :return
  
    def constructor?
      @constructor || false
    end
    
    # @todo i need a @prototype token in object
    def prototype
      children[:prototype]
    end
  
  end 
  
end

CodeObject::Type.register :function, CodeObject::Function

module Token::Handler

  register :function, 
           :handler => :noop, 
           :area => :none,
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
  register :param, :area => :none, :description => "Token for Function-Parameters like '@param [String] name your name'" do |tokenklass, content|

    # it's @param [String] name some content
    if content.lines.first.match TOKEN_W_TYPE_NAME
      self.add_token Token::Handler.apply(:typed_with_name, Token::Token::ParamToken, content)
    
    # it maybe a multiline
    else
      self.add_token Token::Handler.apply(:named_nested_shorthand, Token::Token::ParamToken, content)
    end   
  end


end

Token::Handler.register :return, :handler => :typed, :area => :none, :description => "Returnvalue of a Function"
Token::Handler.register :throws, :handler => :typed

# MethodAlias
CodeObject::Type.register :method, CodeObject::Function
Token::Handler.register :method, :handler => :noop, :area => :none

# @constructor Foo.bar
CodeObject::Type.register :constructor, CodeObject::Function
Token::Handler.register(:constructor) { |token, content| @constructor = true }