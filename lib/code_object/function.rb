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
Token::Handler.register :function, :noop

module Token::Handler

  # @todo maybe allow multipled nested layers of params by parsing them recursivly
  register :param do |token, content|

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
    def parse_named_typed_token(content)  
      typestring, name, content = TOKEN_W_TYPE_NAME.match(content).captures
      types = typestring.split /,\s*/
      NamedTypedToken.new(name, types, content)
    end
    
    # it's @param [String] name some content
    if content.lines.first.match TOKEN_W_TYPE_NAME
      self.add_token token, parse_named_typed_token(content)
    
    # it maybe a multiline
    else
      name = content.lines.first.strip
      types = ['PropertyObject']
      rest_lines = content.split(/\n/)
      
      # remove first line
      rest_lines.shift
      
      # now split line at opening bracket, not at line-break to enable multiline properties
      children = rest_lines.join("\n").strip.gsub(/\s+\[/, "<--SPLIT_HERE-->[").split("<--SPLIT_HERE-->")
   
      children.map! do |child|
        parse_named_typed_token(child)
      end
      
      self.add_token token, NamedTypedTokenWithChildren.new(name, types, "", children)
    end   
  end


end

Token::Handler.register :return, :typed
Token::Handler.register :throws, :typed

# MethodAlias
CodeObject::Type.register :method, CodeObject::Function
Token::Handler.register :function, :noop

# @constructor Foo.bar
CodeObject::Type.register :constructor, CodeObject::Function
Token::Handler.register(:constructor) { |token, content| @constructor = true }