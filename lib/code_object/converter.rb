# ../data.img#1769990:1
require_relative 'function'
require_relative 'exceptions'
require_relative 'type'

# Load Default Tokens
require_relative '../token/tokens'


module CodeObject


  # here the dependencies to {Dom::Node} and {Parser::Comment} should be described
  module Converter
  
    # @see Dom::Node::NODENAME
    NODENAME = /[0-9a-zA-Z$_]+/

    attr_reader :code_object

    def to_code_object

      # 1. Create a new CodeObject from Type-Token
      klass_tokenline = Type.find_klass(@tokenlines)
      return nil if klass_tokenline.nil?  
      
      # Get name from klass_tokenline
      name = extract_name_from klass_tokenline      
      @code_object = Type[klass_tokenline.token].new(name)  
            
      # join all documentation-contents
      @code_object.docs = @doclines.join ''     
      
      # move meta-information from comment to code_object
      # (This includes filepath, source and line_start
      @code_object.clone_meta(self)
           
      # 2. Process Tokenlines with registered handlers
      @code_object.process_tokens(@tokenlines)
      
      # 3.Continue with all children of this comment and add them as
      #   child nodes
      convert_children { |child| @code_object.add_node(child) }
      
      return @code_object
    end        
    
    protected
    
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
    def extract_name_from(tokenline)
      
      path = tokenline.content.split(/\s/).first
    
      match = path.reverse.match /(#{NODENAME})(?:\..*|$)/     
      raise NoNameInPath.new(path) if match.nil?      
      
      match[1].reverse
    end
    
    # recursivly process all child-tokens
    def convert_children
      @children.each do |child_comment|
        code_object = child_comment.to_code_object
        yield(code_object) unless code_object.nil?
      end
    end
    
  end
end
