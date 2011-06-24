require_relative 'token'

# This module contains all required mixins and modules to register customized tokens, that will be 
# further processed and added to the {CodeObject::Base}.
#
# The {CodeObject::Converter converter} starts the {Parser::Tokenline tokenline}-processing, by 
# calling the mixed-in function {Token::Container#process_token}.
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
# Tokenprocessing means analysing the tokenline (plain textual content associated with a token) by
# applying a tokenhandler to it. The tokenhandler should parse the tokenline into it's contents and
# afterwards create an instance of the token-class.
module Token

  # @note This module is **not** built to be used as a mixin! It should be seen as
  #  a **global singleton** instead.
  # 
  # The {Token::Handler} is meant to be the global store for all Token-handlers.
  # Token-handlers are needed to process all {Parser::Tokenline tokenlines} associated with
  # each comment. The following sample, shows a comment including a token line:
  #
  #     /**
  #      * @foo this is a default tokenline
  #      */
  #
  # This comment will be transformed by the {Parser::CommentParser} into a
  # {Parser::Tokenline tokenline} like the following:
  #
  #     puts my_tokenline
  #     #=> <struct Parser::Tokenline token="foo", content="this is a default tokenline"> 
  #
  # After creating the right type of {CodeObject::Base CodeObjects} (either an
  # {CodeObject::Object Object}, {CodeObject::Object Function} or a custom type) the 
  # {CodeObject::Converter converter} will trigger the conversion to an appropriate subclass of
  # {Token::Token} by calling {Token::Container#process_token #process_token}
  # on the CodeObject.
  #
  #     code_object.process_token(my_tokenline)
  #     code_object.token(:token)
  #     #=> [#<Token::FooToken content="this is a default tokenline">]
  #
  # Tokens are always stored in an array to make multiple usage in one comment possible.
  # For example one function-comment can contain many `@param`s:
  #    
  #     /**
  #      * @function foo
  #      * @param [Number] bar
  #      * @param [String] baz
  #      */
  #
  # Default Handlers
  # ================
  # 
  # :text_only
  # ----------
  # The default Header :text_only cannot parse typelists or tokennames, it
  # only saves the content of the token to an instance of {Token::Token}
  # Being the default handler we can use it without explicitly specifying it:
  #
  #      Token::Handler.register :token
  # 
  # This Default Handler is enough for tokens like `@todo` or `@note`. But for
  # more complex Tokens we need some other handlers.
  #
  # :typed
  # ------
  # Typed tokens look like 
  #
  #     @return [Foo, Bar] This is the description
  #
  # Additional to their default **content** they specify the possible **types** as a commaseperated 
  # list.
  #  
  # To register a typed-token, you only need to add the `:handler` option
  #  
  #     Token::Handler.register :return, :handler => :typed
  #  
  # This line implicitly generates a class `Token::ReturnToken` which extends {Token::Token},
  # content and types will be filled to access them later:
  #
  #     my_return_token.content #=> "This is the description"
  #     my_return_token.types   #=> ["Foo", "Bar]
  #
  # :named
  # ------
  # Named tokenlines like
  #
  #     @mixin Foo.bar The description of this mixin-usage
  #
  # interpret the first part (`Foo.bar`) as **name** and the rest as **content**
  #
  #     Token::Handler.register :mixin, :handler => :named
  #     
  #     mixin_token.name    #=> "Foo.bar"
  #     mixin_token.content #=> "The description of this mixin-usage"
  #
  # :named_multiline
  # ----------------
  # Named multiline are similiar to named tokenlines. But instead of taking the first word as
  # name they are using the first line:
  #
  #     @example this is the name
  #       function() {...}
  #
  # To register a named-multiline token just add the handler like:
  # 
  #     Token::Handler.register :example, :handler => :named_multiline
  #
  #     my_example.name    #=> "this is the name"
  #     my_example.content #=> "function() {...}"
  #
  # :typed_with_name
  # ----------------
  # The typed_with_name handler is much like the **Typed-Token-Handler**. It is neccessary for
  # tokenlines, like
  #
  #     @param [String] my_param This is a param
  #
  # Additional to **content** and **types** the generated class will contain a **name** property.
  #
  #     Token::Handler.register :param, :handler => :typed_with_name   
  #     
  #     param_token.name     #=> "my_param"
  #     param_token.types    #=> ["String"]
  #     param_token.content  #=> "This is a param"
  #     param_token.class    #=> Token::ParamToken
  #
  # :named_nested_shorthand
  # -----------------------
  # named_nested_shorthand can be used to parse nested `:typed_with_name` tokens.
  # 
  #     @param person
  #       [String] name the name
  #       [Number] age the age of the person
  #
  # It is called shorthand, because "`[String] name the name`" is not a full tokenline. (The 
  # `@param` is missing.)
  #
  #     Token::Handler.register :param, :handler => :named_nested_shorthand 
  #
  # The instance of `Token::ParamToken` can look like:
  # 
  #     param_token.name     #=> "person"
  #     param_token.children # [<Token::ParamToken name="name"><Token::ParamToken name="age">]
  #
  # It also can parse typed_with_name tokenlines like `@param [String] name`. In this case it
  # behaves exaclty like :typed_with_name
  #
  # :noop
  # ----- 
  # Can be used, if you don't want to do anything with that token
  # 
  # @see .register
  module Handler
  
    ALL = /./m
    NO_BR = /((?!\n)\s)/
    IDENTIFIER = /(?:[^\s])*/
    TYPELIST = /\[(?<types>#{IDENTIFIER}(?:,#{NO_BR}*#{IDENTIFIER})*)\]/
    
    # Tokens with name and content
    NAME = /#{NO_BR}*(?<name>#{IDENTIFIER})#{NO_BR}*(?<content>#{ALL}*)/
    
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
        tokenklass.new(:content => content)
      },
      
      :typed => ->(tokenklass, content) {
        typestring, content = TOKEN_W_TYPE.match(content).captures
        types = typestring.split /,\s*/
        
        tokenklass.new(:types => types, :content => content)
      },
      
      :named => ->(tokenklass, content) {
        name, content = NAME.match(content).captures        
        tokenklass.new(:name => name, :content => content)
      },
       
      :named_multiline => ->(tokenklass, content) { 
        rows = content.split(/\n/)
              
        # use first row as name
        name = rows.shift.strip
        content = rows.join("\n")
              
        tokenklass.new(:name => name, :content => content)
      },

      :typed_with_name => ->(tokenklass, content) {
        typestring, name, content = TOKEN_W_TYPE_NAME.match(content).captures
        types = typestring.split /,\s*/
        
        tokenklass.new(:name => name, :types => types, :content => content)
      },
      
      :named_nested_shorthand => ->(tokenklass, content) {
          
        # First remove linebreaks with 2-times intendation (= continuation)    
        lines         = content.gsub(/\n((?!\n)\s){2}/, ' ').split(/\n/)
        name          = lines.shift.strip
        documentation = []
        children      = []
        
        lines.each do |line|          
          if TOKEN_W_TYPE_NAME.match(line)
            # apply handler :typed_with_name to each child-line
            # @todo maybe we need a special way to select Children's Class?
            children << Handler.apply(:typed_with_name, tokenklass, line)
          else
            documentation << line
          end
        end
      
        tokenklass.new(:name => name, :types => [], :children => children, :content => documentation.join("\n"))   
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
    
    # Use a default handler
    def self.apply(default_handler, *args)
      @@defaults[default_handler].call(*args)
    end
    
    def self.add_default_handler(name, &block)
      @@defaults[name] = block;
    end
    
    # It is possible to register your own Tokenhandlers and therefore extend the capabilities of 
    # this documentation-tool (See: {file:CUSTOMIZE.md CUSTOMIZE}).
    #
    # There are different types of handlers which can be used out of the box. Further documentation
    # about the default handlers can be found {Token::Handler in the introduction}.
    #
    # Writing your own custom Token-Handler
    # -------------------------------------
    # By adding the optional block you easily can build your own Tokenhandler:
    #
    #      Token::Handler.register(:my_own) do |token_klass, stringcontent|
    #        # Do something with token_klass and stringcontent
    #        # but don't forget to add the token like, if you want to access it from the templates:
    #        # token_klass will be Token::MyOwnToken, which is dynamically created during registration
    #
    #        self.add_token(token_klass.new(:content => stringcontent)
    #      end
    #
    # Because the token processing is done in the **context of the CodeObject** you
    # can easily extend or manipulate the Object.
    #
    # @param [String, Symbol] tokenname
    # @param [Hash] options
    # @option options [Symbol] :handler (:text_only)
    # @option options [Symbol, String] :template (:default) The template for this token-collection
    # @option options [Hash] :html ({}) Attributes which can be added to the html-representation of 
    #   this token. For example use 
    #       :html => { :class => 'big_button' } 
    #   to add the class `.big_button` to the html-element. Please note, that your template has to 
    #   render the html-attributes explicilty. For example by adding 
    #       <div <%= attributize token.html %>>...</div>
    # @option options [Symbol] :area (:body) The area the tokens will be rendered in. The default 
    #   templates make use of (:notification|:body|:sidebar|:footnote), but you can use any symbol 
    #   here.
    # @option options [String] :description ("") The description specified here will appear in the
    #   command-line output of `docjs tokens`
    # 
    # @yield [tokenklass, stringcontent] Your custom tokenhandler
    # @see Token::Token
    def self.register(tokenname, options = {}, &handler)
      
      tokenname = tokenname.to_sym   
      
      # search matching handler
      if block_given?
        # handler is already defined
      elsif options[:handler] and @@defaults.include?(options[:handler])
        handler = self.build_handler(options[:handler])
      elsif options[:handler]
        raise Exception, "#{type} has no registered Tokenhandler"
      else
        handler = self.build_handler(:text_only)
      end      
      
      # Dynamically create Class named TokennameToken
      camelcased = tokenname.to_s.capitalize.gsub(/_\w/){|w| w[1].capitalize}
      klass = Token.const_set "#{camelcased}Token", Class.new(Token)
      
      klass.process_options options.merge({
      
        :token    => tokenname,
        :handler  => handler
      
      });  
      
      @@handlers[tokenname] = klass
    end
    
    # Remove a registered handler from the list.
    # 
    # @todo remove symbol `Token::TokennameToken`
    #
    # @example
    #   Token::Handler.register :foo
    #   Token::Handler.unregister :foo
    #
    # @param [String, Symbol] tokenname
    def self.unregister(tokenname)
      @@handlers.delete(tokenname.to_sym)
    end    
    
    protected
    
    def self.build_handler(type)
      
      handler =  @@defaults[type]
    
      ->(tokenklass, content) {
        token = instance_exec(tokenklass, content, &handler)
        self.add_token token unless token.nil? # can be NOOP
      }
    end

  end  
end
