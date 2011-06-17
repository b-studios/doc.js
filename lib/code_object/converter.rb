# ../data.img#1769990:1
require_relative 'function'
require_relative 'exceptions'
require_relative 'type'

module CodeObject


  # here the dependencies to {Dom::Node} and {Parser::Comment} should be described
  module Converter
  
    attr_reader :code_object, :path

    def to_code_object

      # 1. Create a new CodeObject from Type-Token   
      @code_object = find_type_for(@tokenlines) or return nil
            
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

    
    # recursivly process all child-tokens
    def convert_children
      @children.each do |child_comment|
        code_object = child_comment.to_code_object
        yield(code_object) unless code_object.nil?
      end
    end
    
    
    def find_type_for(tokenlines)
    
      # all_types returns a hash like {:object => CodeObject::Object ...}
      available_types = CodeObject.all_types
    
      types = tokenlines.select {|t| available_types.has_key? t.token }
      
      if types.size > 1
        raise CodeObject::MultipleTypeDeclarations.new, "Wrong number of TypeDeclarations: #{types}"
      elsif types.size == 0
        # it's not possible to create instance
        return nil
      end
      
      type = types.first
      
      # Get Class and instantiate it with content
      klass = available_types[type.token]
      klass.new(type.content)
    end
    
    
  end
end
