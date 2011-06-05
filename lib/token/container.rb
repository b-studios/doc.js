# ../data.img#1811394:1
require_relative 'exceptions'
require_relative 'handler'

module Token

  module Container
    
    def initialize
      super
      @tokens = {}
    end
    
    # provides access to tokens, trough token identifier
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
    
    def tokens
      @tokens
    end

    def add_token(token)     
      @tokens[token.token] ||= []
      @tokens[token.token] << token
    end
    
    # @param [Parser::Tokenline] tokenline consisting of :token and :content
    # then calls matching tokenhandler (if exists) with data in `this`-context
    # @todo only raise error, if config is set to whiny
    def process_token(tokenline)
    
      # try to find matching tokenklass for token i.e. Token::Token::ParamToken for :param
      tokenklass = Token.const_get "#{tokenline.token.capitalize.to_s}Token"
    
      raise NoTokenHandler.new("No Tokenhandler for: #{token_name}") if tokenklass.handler.nil?
      
      instance_exec(tokenklass, tokenline.content, &(tokenklass.handler))
    end
    
    # Plural version of {#process_token}
    #
    # @param [Array<Parser::Tokenline>] tokenlines
    def process_tokens(tokenlines)
      tokenlines.each {|tokenline| process_token(tokenline) }
    end
    
    protected    
    
    def has_to_be_a(type)
      raise WrongType.new("Not a valid Type:#{type}") unless self.is_a? type
    end
    
  end
  
end
