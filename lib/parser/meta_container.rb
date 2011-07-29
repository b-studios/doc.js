module Parser

  # Is included by {CodeObject::Base} and {Parser::Comment} and stores Metainformation like
  #
  # - **filepath** of the JavaScript-File, where the comment is extracted from
  # - **source** of the JavaScript-Scope, which begins just after the comment ends.
  # - **line_start** - Linenumber of the first scope-line
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

