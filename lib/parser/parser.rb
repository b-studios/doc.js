# ../data.img#1869414:2
require 'strscan'
require_relative 'comment_parser'

#
# ![Parser Overview](../uml/Parser.svg)
#
#
module Parser

  NO_BR = /((?!\n)\s)/
  ALL = /./m
  
  # Multiline Comments
  M_START = /\/\*+/
  
  # End of multiline comment with all leading whitespaces (no breaks)
  M_END = /#{NO_BR}*\*+\//
  
  # Singleline Comments
  S_START = /\/\//
  S_END = /\n/

  
  LINE_START = /(#{NO_BR})*\*+#{NO_BR}?/
  LINE_END = /\n/
  EMPTY_LINE = /^\s*$/
    
  # CAUTION: \s can contain breaks "\n"
  TOKENLINE_START = /\s*@/
  TOKENLINE = /
    #{TOKENLINE_START}
      (?<name>\w+)
      (?:#{NO_BR}?(?<content>#{ALL}+)|$)
    /x
    
  # String delimiter
  S_STRING = /'/
  D_STRING = /"/
  
  REGEXP_START = /\/[^\/]/
  REGEXP_END = /\//
  
  NON_COMMENT_PATTERNS = {
    S_STRING     => S_STRING,
    D_STRING     => D_STRING,
    REGEXP_START => REGEXP_END  
  } 
  
  NON_CODE_PATTERNS = {    
    M_START      => M_END,
    S_START      => S_END,
    S_STRING     => S_STRING,
    D_STRING     => D_STRING,
    REGEXP_START => REGEXP_END    
  } 
   
  class Parser
  
    attr_reader :filepath, :offset
  
    # A new StringScanner instance will be used to {#parse parse} the given
    # `input`.
    #
    # @param [String] input
    def initialize(input, args = {})
      
      raise Exception, "Expected input to be a String, got #{input.class}" unless input.is_a? String
      
      # Default Values
      @filepath = args[:filepath]  || "No File specified"
      @offset   = args[:offset]    || -1 # we are adding 1 later
      
      
      # clean input and convert windows linebreaks to normal ones
      @to_parse = input.gsub(/\r\n/, "\n")
      @scanner = StringScanner.new @to_parse
      @comments = []
    end  
    
    
    # Recursivly parses the {#initialize given input} and thereby ignores
    # strings.
    # @todo Rewrite to use skip_intelligent_until
    # @return [Array<Parser::Comment>] the parsed comment-stream
    def parse()
      @scanner.skip /\s/
      @scanner.skip_until /#{M_START}|#{S_START}|#{NON_COMMENT_PATTERNS.keys.join('|')}|$/
      
      found = @scanner.matched
      
      if found.match M_START
        parse_comment_until(M_END)
        
      elsif found.match S_START
        parse_comment_until(S_END)
        
      else
        NON_COMMENT_PATTERNS.each do |start_pattern, end_pattern|    
          if found.match start_pattern
            @scanner.skip_escaping_until end_pattern         
            break
          end    
        end
      end
      
      if @scanner.eos?
        return @comments
      else
        parse
      end
    end
    
    def self.parse_file(path)
      stream = File.read path
      Parser.new(stream, :filepath => path).parse
    end
    
    protected
    
    def parse_comment_until(ending)
      content = @scanner.scan_until_ahead ending      
      comment = CommentParser.new(content).parse unless content.nil?  
           
      # only proceed, if it is a tokenized comment
      return parse unless comment.has_tokens?  
      
      # search scope for that comment
      @scanner.skip /\n/
      scope = @scanner.save_scanned { find_scope } 
              
      code_line = @to_parse.line_of(scope.min) + @offset + 1
      source = @to_parse[scope]     
      
      # Add Metadata
      comment.add_meta_data @filepath, source, code_line   
      
      # Save Comment
      @comments << comment
      
      comment.add_children Parser.new(source, :filepath => @filepath, :offset => code_line-1).parse      
    end    
    
    def find_scope(scope_stack = [], ignore_line_end = false)

      if ignore_line_end    
        return if scope_stack.empty?      
        @scanner.skip /\s/
      end
      
      # adding |$ only if we don't ignore line_ends (which is most of the time)
      @scanner.intelligent_skip_until /\{|\(|\}|\)#{'|$' unless ignore_line_end}/
      
      match = @scanner.matched
      
      case match
      when '{'
        find_scope(scope_stack << '}', ignore_line_end)
        
      when '('          
        find_scope(scope_stack << ')', ignore_line_end)
        
      when '}', ')'
        if(scope_stack.last == match)
          scope_stack.pop
          find_scope(scope_stack, ignore_line_end)
        else
          # currently just ignore non matching closing pairs
          puts "I'm ignoring #{match} at #{@scanner.pos} of #{@filepath}"
        end      
      else
        
        if ignore_line_end
          if not @scanner.eos?
            find_scope(scope_stack, ignore_line_end)
            
          elsif not scope_stack.empty?
            raise "Unmatched Scope-Stack: #{scope_stack}"
          end
        
        else        
          find_scope(scope_stack, true)  unless scope_stack.empty?
        end
      end 
    end    
        
  end
  
end

# We have to extend StringScanner a little bit to fit our needs.
#
# @see Parser::Parser
# @see Parser::CommentParser
class StringScanner  
  
  # returns the string until `pattern` matches, then consums `pattern`
  #
  # @example
  #   scanner = StringScanner.new("hello     world")
  #   scanner.scan_until_ahead(/\s+/) #=> "hello"
  #   scanner.pos #=> 5
  #
  # @param [Regexp] pattern the pattern to scan until
  # @return [String] the String before `pattern`
  def scan_until_ahead(pattern)
    content = self.scan_until /(?=(#{pattern}))/
    self.skip pattern
    return content
  end
  
  # will stop to scan at the specified pattern or at eos and returns the
  # consumed string.
  # 
  # @param [Regexp] pattern the pattern to scan for
  # @return [String] the String before `pattern`
  def scan_until_or_end(pattern)
    self.scan_until(pattern) or self.scan_until(/$/)
  end
  
  # skips content within comments, strings and regularexpressions
  def intelligent_skip_until(pattern)

    self.skip_escaping_until(/#{pattern}|#{Parser::NON_CODE_PATTERNS.keys.join('|')}/)

    found = self.matched
    
    raise end_of_string_error(pattern) if self.matched.nil?
    
    return if found.match pattern
    
    Parser::NON_CODE_PATTERNS.each do |start_pattern, end_pattern|    
      if found.match start_pattern
        self.skip_escaping_until end_pattern
        return self.intelligent_skip_until pattern
      end    
    end
  end
  
  def save_scanned
    pos_start = self.pos #- 1 # fixes missing first char
    yield
    pos_end = self.pos
    Range.new(pos_start, pos_end)
  end
  
  def skip_escaping_until(pattern) 
       
    self.skip_until(/\\|#{pattern}/)
    
    raise end_of_string_error(pattern) if self.matched.nil?

    if self.matched.match /\\/
      self.getch
      skip_escaping_until(pattern)
    end    
  end
  
  protected
  
  def end_of_string_error(pattern)
    Error.new "Unexpected end of String, expected: #{pattern.inspect} in \"#{self.string}\" at pos:#{self.pos}"
  end  

end

class String
  def line_of(pos)
    self[0..pos].count "\n"
  end
end
