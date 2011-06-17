module Parser

  # is included by {CodeObject::Base} and {Parser::Comment}
  module MetaContainer
  
    attr_reader :filepath, :source, :line_start
  
    def add_meta_data(filepath, source, line_start)
      @filepath, @source, @line_start = filepath, source, line_start+1 # counting from 1
    end
    
    def clone_meta(other)
      @filepath, @source, @line_start = other.filepath, other.source, other.line_start
    end
  
  end

end

