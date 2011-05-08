# ../data.img#1799299:1
require_relative 'comment'
require_relative 'exceptions'

module Parser
  class CommentParser < StringScanner    

    def initialize(input)
      super(input)
      @comment = Comment.new(input)
    end

    # All lines, that start with a `@-symbol` will be processed as tokenline
    # if the next line after a token starts with two spaces, it will be 
    # interpreted as continuation of the preceding token.
    #
    # @example multiline token
    #   @multiline_token this is a multi_line token, it won't
    #     stop if i intend the next line with two spaces, like "  "
    #
    # All other lines are interpreted as doclines
    #
    # @return [Parser::Comment] Creates an instance of {Parser::Comment} and
    #   attaches all find doc- and tokenlines to it.
    def parse
      # we don't want the linebreak of the comment start in our first docline
      # i.e. ignore '/**\n' 
      self.skip LINE_END
      
      while not eos? do
        parse_comment_line
      end
      return @comment
    end
    
    protected
    
    # skips leading spaces with asterisk aka {Parser::LINE_START LINE_START}
    # then checks for {Parser::TOKENLINE_START @-symbol} to parse a token
    def parse_comment_line
      self.skip LINE_START
      
      if self.check TOKENLINE_START
        tokenline = parse_token
        matches = tokenline.match(TOKENLINE)
        
        # puts "Tokenline:#{tokenline}"
        
        raise NotValidTokenline.new("Not valid:'#{tokenline}'") if matches.nil?
        
        name, content = matches.captures
        @comment.add_tokenline(name, content)
      else
        @comment.add_docline parse_doc
      end
    end
    
    # Parses tokens, if the line begins with an @
    #     @token_one some other text etc.
    #
    # The parser does the following to detect multiline tokens like:
    #     @token_two some text, and some more
    #       and even some more.
    #
    #   1. Scan til the first linebreak (or end of string, if it reaches it first)
    #   2. Check if next line starts with two spaces, skip them
    #   3. Parse recursivly til the next line does not start with two spaces
    #
    # @see StringScanner.scan_until_ahead to see another example
    #   of the positive lookahead
    def parse_token
    
      # scan until the first linebreak, but don't include it in the `content`
      # content = self.scan_until_or_end(/(?=(#{LINE_END}))/)
      # so just skip it
      # self.skip LINE_END
      content = self.scan_until_or_end LINE_END
      
      # skip the first two spaces and parse line recursivly
      unless self.skip(/#{LINE_START}#{NO_BR}{2}/).nil?
        content + " " + parse_token
      else
        content
      end
    end
    
    def parse_doc
      self.scan_until_or_end(LINE_END)
    end
    
  end
end
