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
Token::Handler.register :function, :handler => :noop, :area => :none

module Token::Handler

  # We want to support either named-typed-tokens like
  #  @param [Foo] barname some description
  #
  # or multiline tokens like:
  #  @param configs
  #    [String] foo some string
  #    [Bar] bar and another one
  #
  #
  # if out content matches something with `[` at the beginning, it seems to be
  # a normal named-typed-token
  # it's a little tricky because we still want to allow multiline descriptions of each param
  register :param, :area => :body do |tokenklass, content|


    # it's @param [String] name some content
    if content.lines.first.match TOKEN_W_TYPE_NAME
      self.add_token Token::Handler.apply(:typed_with_name, Token::Token::ParamToken, content)
    
    # it maybe a multiline
    else
      lines = content.split(/\n/)
      name = lines.shift.strip
      types = ['PropertyObject']
      
      # now split line at opening bracket, not at line-break to enable multiline properties
      children = lines.join("\n").strip.gsub(/\s+\[/, "<--SPLIT_HERE-->[").split("<--SPLIT_HERE-->")
   
      children.map! do |child|
        # apply default-handler :typed_with_name to each child-line
        Token::Handler.apply(:typed_with_name, Token::Token::ParamToken, child)
      end
      
      self.add_token tokenklass.new(:name => name, :types => types, :children => children)
    end   
  end


end

Token::Handler.register :return, :handler => :typed
Token::Handler.register :throws, :handler => :typed

# MethodAlias
CodeObject::Type.register :method, CodeObject::Function
Token::Handler.register :method, :handler => :noop, :area => :none

# @constructor Foo.bar
CodeObject::Type.register :constructor, CodeObject::Function
Token::Handler.register(:constructor) { |token, content| @constructor = true }