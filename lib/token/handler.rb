# ../data.img#1799432:1 && #1858562:1
require_relative 'token'

# This module contains all required mixins and modules to register customized
# tokens, that will be further processed and added to the {CodeObject::Base}.
#
# The {CodeObject::Converter converter} starts the {Parser::Tokenline tokenline}-processing, by calling
# the mixed-in function {Token::Container#process_token}.
#
# ![Token UML](../uml/Tokens.svg)
#
# The illustration above shows the **two modules** included in {Token}:
#
#   1. {Token::Handler}, which can be used to register new token-handlers.
#   2. {Token::Container}, which is included in {CodeObject::Base} to add 
#       individual token-{Token::Container#add_token container} and 
#       {Token::Container#process_token -processing} functionality to all CodeObjects.
#
module Token

  # @note This module is **not** built to be used as a mixin! It should be seen as
  #  a **global singleton** instead.
  # 
  # The {Token::Handler} is meant to be the global store for all Token-handlers.
  # Token-handlers are needed to process incoming {Parser::Tokenline tokenlines}
  # of each comment. The following sample, shows a comment including a token line:
  #
  #     /**
  #      * @token this is a default tokenline
  #      */
  #
  # This Comment will be transformed by the {Parser::CommentParser} into a
  # {Parser::Tokenline tokenline} like the following:
  #
  #     puts my_tokenline
  #     #=> <struct Parser::Tokenline token="token", content="this is a default tokenline"> 
  #
  # After creating the right type of {CodeObject::Base CodeObjects} (either a
  # {CodeObject::Object Object} or {CodeObject::Object Function}) the 
  # {CodeObject::Converter converter} will trigger the conversion to a 'real' 
  # {Token::Handler::Token token} by calling {Token::Container#process_token #process_token}
  # on the CodeObject.
  #
  #     code_object.process_token(my_tokenline)
  #     code_object.token(:token)
  #     #=> [#<struct Token::Handler::Token content="this is a default tokenline">]
  #
  # Tokens are always stored in an array to make multiple usage in one comment
  # possible.
  #
  # @see .register
  module Handler
  
    ALL = /./m
    NO_BR = /((?!\n)\s)/
    IDENTIFIER = /(?:[^\s])*/
    TYPELIST = /\[(?<types>#{IDENTIFIER}(?:,#{NO_BR}*#{IDENTIFIER})*)\]/
    
    # Token with type and content
    TOKEN_W_TYPE = /#{NO_BR}*#{TYPELIST}#{NO_BR}*(?<content>#{ALL}*)/
    
    # Token with type, name and content
    TOKEN_W_TYPE_NAME =  /^#{NO_BR}*
      #{TYPELIST}#{NO_BR}*
      (?<name>#{IDENTIFIER})
      #{NO_BR}*
      (?<content>#{ALL}*)
    /x
    
    @@defaults = {
      :text_only => ->(tokenklass, content) {
          self.add_token tokenklass.new(:content => content)
      },
      
      :typed => ->(tokenklass, content) {
        typestring, content = TOKEN_W_TYPE.match(content).captures
        types = typestring.split /,\s*/
        
        self.add_token tokenklass.new(:types => types, :content => content)
      },

      :typed_with_name => ->(tokenklass, content) {
        typestring, name, content = TOKEN_W_TYPE_NAME.match(content).captures
        types = typestring.split /,\s*/
        
        self.add_token tokenklass.new(:name => name, :types => types, :content => content)
      },
      
      :named_multiline => ->(tokenklass, content) { 
        rows = content.split(/\n/)
              
        # use first row as name
        name = rows.shift.strip
        content = rows.join("\n")
              
        self.add_token tokenklass.new(:name => name, :content => content)
      },
      
      :noop => ->(tokenklass, content) {}
    } 
    @@handlers = {}    
    
    # Attribute-Reader for all registered `@@handlers`
    #
    # @return [Hash<Symbol, Block>]
    def self.handlers
      @@handlers
    end
    
    # Registering a new Tokenhandler
    # ==============================
    # It is possible to register your own Tokenhandlers and therefore extend the
    # capabilities of this documentation-program.
    #
    # There are different types of handlers which can be used:
    #
    #   1. Default-handler
    #   2. A handler for Typed-Token
    #   3. A handler for Named-Typed-Tokens
    #   4. Your custom handler (see second overload)
    #
    #
    # @overload self.register(tokenname, type=nil)
    #  
    #  The first three of the handlers above can be registered with this
    #  overload.
    #  
    #  The Default Handler
    #  -------------------
    #  The Default Header can be used for tokens like the one in the example above.
    #  Trying to add a token like `@token` without adding a handler, you may get
    #  an `exception` like:
    #  
    #       #=> Token::NoTokenHandler: No Tokenhandler for: token
    #       #     from lib/token/container.rb:41:in process_token
    #  
    #  So we better register a handler for that token:
    #  
    #      Token::Handler.register :token
    #  
    #  As you can see **the second argument can be ommitted** to use a **default 
    #  handler**. This default handler cannot parse typelists or tokennames, it
    #  only saves the content of the token to the struct {Token::Handler::Token Token}.
    #  
    #  This Default Handler is enough for tokens like `@todo` or `@note`. But for
    #  more complex Tokens we need some other handlers.
    #  
    #  Handler for Typed-Tokens
    #  ------------------------
    #  Typed tokens look like `@return [Foo, Bar] This is the description` - Additional
    #  to their **default content** they specify the possible Types.
    #  
    #  To register a typed-token, you only need to add a second argument:
    #  
    #       Token::Handler.register :return, :typed
    #  
    #  The {Token::Handler::TypedToken typed-token struct}, pretty much looks like 
    #  the default one.
    #  
    #       #=> #<struct Token::Handler::TypedToken types=["Foo", "Bar"], content="This is the description\n">
    #
    #  Handler for Typed-Named-Tokens
    #  ------------------------------
    #  They are much like **Typed-Token-Handlers**. They are needed for Tokenlines
    #  like `@param [String] my_param This is a param`. They are registered with
    #  `:typed_with_name` as the second argument:
    #  
    #       Token::Handler.register :param, :typed_with_name
    #  
    #  @param [String, Symbol] tokenname
    #  @param [:typed, :typed_with_name, nil] type
    #
    #
    # @overload self.register(tokenname, &handler)
    #  
    #  Writing your own custom Token-Handler
    #  -------------------------------------
    #  By adding a block in the Tokenregistration you easily can build your own
    #  Tokenhandler:
    #
    #       Token::Handler.register(:my_own) do |token_klass, stringcontent|
    #         # Do something with token_id and stringcontent
    #         # but don't forget to add the token like:
    #         self.add_token(token_klass.new(:content => stringcontent)
    #       end
    #
    #  Because the token processing is done in the **context of the CodeObject** you
    #  can easily extend or manipulate the Objects.
    #  
    #  If you want to assure, that the object you are working on has a specific type
    #  (for example a Function) add the following line to your handler:
    #
    #       has_to_be_a CodeObject::Function
    #
    #  @param [String, Symbol] tokenname
    #  @yield [tokenklass, stringcontent] Your custom tokenhandler
    # 
    def self.register(tokenname, options = {}, &handler)
      
      tokenname = tokenname.to_sym   
      
      # search matching handler
      if block_given?
        # handler is already defined
      elsif options[:handler] and @@defaults.include?(options[:handler])
        handler = @@defaults[options[:handler]]
      elsif options[:handler]
        raise Exception, "#{type} has no registered Tokenhandler"
      else
        handler = @@defaults[:text_only]
      end      
      
      # Dynamically create Class named TokennameToken
      klass = Token.const_set "#{tokenname.to_s.capitalize}Token", Class.new(Token)
      
      klass.process_options options.merge({
      
        :token    => tokenname,
        :handler  => handler
      
      });  
      
      @@handlers[tokenname] = klass
    end
    
    # Remove a registered handler from the list
    #
    # @example
    #   Token::Handler.register :foo
    #   Token::Handler.unregister :foo
    #
    # @param [String, Symbol] tokenname
    def self.unregister(tokenname)
      @@handlers.delete(tokenname.to_sym)
    end
    
    def self.add_default_handler(name, &block)
      @@defaults[name] = block;
    end

  end  
end
