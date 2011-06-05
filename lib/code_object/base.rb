# ../data.img#1787927:1
require_relative '../token/container'
require_relative '../dom/dom'
require_relative '../parser/meta_container'

#
# ![Code Object Overview](../uml/CodeObject.svg)
#
#
module CodeObject

  class Base

    include Token::Container
    include Dom::Node
    include Parser::MetaContainer
      
    attr_reader :docs, :name, :path
    
    # The name instance variable is required by Dom::Node
    def initialize(path = "NO_PATH_SPECIFIED")      
      path = path.to_s.split(/\s/).first # remove trailing spaces    
      @path, @name = path, extract_name_from(path)
      super()
    end    
    
    def to_s
      token_names = @tokens.keys if @tokens
      "#<#{self.class}:#{self.name} @parent=#{parent.name if parent} @children=#{@children.keys} @tokens=#{token_names}>"
    end    
    
    # Automatically converts markdown-documentation to html
    def docs=(docstring)
      @docs = docstring.strip
    end
    
    protected
    
    # This is a Helpermethod, which can be used in subclasses like CodeObject::Function
    def self.token_reader(name, token = name)
      define_method name do
        self.token(token)
      end
    end   
  
  end
 
end
