require_relative 'exceptions'

module Token
  
  # Each {CodeObject} serves as Token::Container. This module encapsulates all required methods
  # to {#process_token convert Tokenlines to Tokens}, {#add_token add Tokens} and {#token query the stored tokens}.
  module Container
    
    def initialize
      super
      @tokens = {}
    end
    
    # provides access to tokens, through token identifier
    #
    # @example
    #   obj.token :public
    #   #=> #<struct Token::Handler::Token content=nil> 
    #
    # @param [String, Symbol] tokenname the tokenidentifier like :public
    # @return [Token] the token with it's content 
    def token(tokenname)
      @tokens[tokenname.to_sym]
    end
    
    # @return [Hash<Symbol, Array<Token::Token>>] all tokens of this container
    def tokens
      @tokens
    end

    # @overload add_token(tokenid, token)
    #   @param [Symbol] tokenid
    #   @param [Token::Token] token
    #
    # @overload add_token(token)
    #   @param [Token::Token] token
    def add_token(tokenid_or_token, token=nil)     
    
      unless token.nil?
        tokenid = tokenid_or_token
      else
        tokenid = tokenid_or_token.token
        token = tokenid_or_token
      end
      
      @tokens[tokenid] ||= []
      @tokens[tokenid] << token
    end
    
    # tries to find matching tokenklass for token i.e. Token::Token::ParamToken for :param
    # then calls matching tokenhandler (if exists) with data in `this`-context
    #
    # @param [Parser::Tokenline] tokenline consisting of :token and :content
    #
    # @todo only throw NoTokenHandler, if this really is the problem
    def process_token(tokenline)
   
      begin
        camelcased = tokenline.token.to_s.capitalize.gsub(/_\w/){|w| w[1].capitalize}
        tokenklass = Token.const_get "#{camelcased}Token"
        instance_exec(tokenklass, tokenline.content, &(tokenklass.handler))
      rescue Exception => error
        raise NoTokenHandler.new("No Tokenhandler for: @#{tokenline.token}
This is no big deal. You can add your custom tokenhandler for @#{tokenline.token} by adding the following line to your included ruby-file:

    Token::Handler.register :#{tokenline.token} # optionally add a tokenhandler or target-area (See documentation for more infos)
    
After this using '@#{tokenline.token}' in your documentation is no problem...\n\n" + error.message)
      end
    end
    
    # Plural version of {#process_token}
    #
    # @param [Array<Parser::Tokenline>] tokenlines
    def process_tokens(tokenlines)
      tokenlines.each {|tokenline| process_token(tokenline) }
    end
    
    protected    
    
    def has_to_be_a(type)
      raise WrongType.new("Not a valid Type: '#{type}'") unless self.is_a? type
    end
    
  end
  
end
