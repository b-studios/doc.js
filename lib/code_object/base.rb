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
      @docs = docstring.strip #RDiscount.new(docstring.strip).to_html
    end
    
    protected
        
    def self.token_reader(name, token = name)
      define_method name do
        self.token(token)
      end
    end
    
    # path can be absolute like `Foo.bar`, `Foo` or it can be relative like
    # `.foo`, `.foo.bar`.
    # in both cases we need to extract the name from the string and save it
    # as name. After doing this we can use the path to save to dom. 
    #
    # @example absolute path
    #   Node.extract_name_from("Foo.bar.baz") #=> 'baz'
    #   Node.extract_name_from("Foo.bar.baz") #=> 'baz'
    #    
    # @param [String] path relative or absolute path of node
    # @return [String] the extracted name
    def extract_name_from(path)
      name = path.split('.').last
      raise NoNameInPath.new(path) if name.nil?
      
      return name
    end 
  
  end
 
end
