# ../data.img#1810075:1
require_relative 'exceptions'

module CodeObject
  
  module TokenProcessor
    
    # Default Struct for tokens
    Token = Struct.new :content
    TypedToken = Struct.new :types, :content
    NamedTypedToken = Struct.new :name, :types, :content

    ALL = /./m
    NO_BR = /((?!\n)\s)/
    IDENTIFIER = /(?:[^\s])*/
    TYPELIST = /\[(?<types>#{IDENTIFIER}(?:,#{NO_BR}*#{IDENTIFIER})*)\]/
    
    # Token with type and content
    TOKEN_W_TYPE = /#{NO_BR}*#{TYPELIST}#{NO_BR}*(?<content>#{ALL}*)/
    
    # Token with type, name and content
    TOKEN_W_TYPE_NAME =  /#{NO_BR}*
      #{TYPELIST}#{NO_BR}*
      (?<name>#{IDENTIFIER})
      #{NO_BR}*
      (?<content>#{ALL}*)
    /x
    
    module ClassMethods
      
      @@token_handler ||= {}
        
      # used to register tokenhandlers
      def token(tokenname, type = nil, &handler)      
        #@@token_handler ||= {}
        
        token = tokenname.to_sym
        
        if block_given?        
          @@token_handler[token] = handler
        elsif type == :typed
          @@token_handler[token] = default_handler_with_types
        elsif type == :typed_with_name
          @@token_handler[token] = default_handler_with_types_and_name
        else
          @@token_handler[token] = default_handler
        end
      end
            
      def handlers
        @@token_handler
      end
      
      protected
      
      def default_handler
        ->(token, content) do
          self.add_token token, Token.new(content)
        end
      end
      
      # @todo implement
      def default_handler_with_types
        ->(token, stringcontent) do
          typestring, content = TOKEN_W_TYPE.match(stringcontent).captures
          types = typestring.split /,\s*/
          
          self.add_token token, TypedToken.new(types, content)
        end
      end
      
      # @todo implement
      def default_handler_with_types_and_name
        ->(token, stringcontent) do
          typestring, name, content = TOKEN_W_TYPE_NAME.match(stringcontent).captures
          types = typestring.split /,\s*/
          
          self.add_token token, NamedTypedToken.new(name, types, content)
        end
      end
          
    end
    
    
    # Extend base with our {ClassMethods}
    def self.included(base)
      base.extend ClassMethods
    end
    
    # Instance Methods
    
    def initialize(*args)
      super
      @tokens = {}
    end
      
    # @param [Parser::Tokenline] tokenline consisting of :token and :content
    # then calls matching tokenhandler (if exists) with data in `this`-context
    # @todo only raise error, if config is set to whiny
    def process_token(tokenline)
    
      token_name = tokenline.token.to_sym
    
      raise NoTokenHandler.new("No Tokenhandler for: #{token_name}") unless self.class.handlers.has_key? token_name
      
      block = self.class.handlers[token_name]
      instance_exec(token_name, tokenline.content, &block)
    end
    
    # provides access to tokens, trough token identifier
    #
    # @example
    #   obj.token :public
    #   #=> #<struct CodeObject::TokenProcessor::Token content=nil> 
    #
    # @param [String, Symbol] tokenname the tokenidentifier like :public
    # @return [Token] the token with it's content 
    def token(tokenname)
      @tokens[tokenname.to_sym]
    end
    
    def tokens
      @tokens
    end

    protected    
    
    def has_to_be_a(type)
      raise WrongType.new("Not a valid Type:#{type}") unless self.is_a? type
    end
    
    # @todo add @tokens to initializer or somewhere else
    # @todo change entries to arrays
    def add_token(token_id, token)     
      @tokens[token_id.to_sym] ||= []
      @tokens[token_id.to_sym] << token
    end
  end
  
end
