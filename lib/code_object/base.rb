# ../data.img#1787927:1
require_relative '../token/container'
require_relative '../dom/dom'
require_relative '../parser/meta_container'
require 'rdiscount'

#
# ![Code Object Overview](../uml/CodeObject.svg)
#
#
module CodeObject

  class Base

    include Token::Container
    include Dom::Node
    include Parser::MetaContainer
      
    attr_reader :docs, :name
            
    # The name instance variable is required by Dom::Node
    def initialize(name = "UNNAMED")
      @name = name
      super()
    end    
    
    def to_s
      token_names = @tokens.keys if @tokens
      "#<#{self.class}:#{self.name} @parent=#{parent.name if parent} @children=#{@children.keys} @tokens=#{token_names}>"
    end    
    
    # Automatically converts markdown-documentation to html
    def docs=(docstring)
      @docs = RDiscount.new(docstring.strip).to_html
    end
    
    protected
        
    def self.token_reader(name, token = name)
      define_method name do
        self.token(token)
      end
    end
  
  end
 
end
