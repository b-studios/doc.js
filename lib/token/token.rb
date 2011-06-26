module Token

  # Serves as Base-Class for all registered tokens. Registering a token with 
  #     
  #     Token:Handler.register :awesome, :template => :foo, :description => "Description"
  #
  # is pretty much equivalent to
  #
  #     class Token::AwesomeToken < Token::Token; end
  #     Token::AwesomeToken.process_options({ 
  #       :token       => :awesome,
  #       :template    => :foo,
  #       :description => "Description" 
  #     })
  class Token

    attr_reader :name, :content, :types, :children
    
    def initialize(args = {})    
      @name = args[:name]
      @types = args[:types]
      @children = args[:children]      
      @content = args[:content] || ""
    end    
    
    # Processes the options, which are added while registering the new token-handler
    #
    #     Token:Handler.register :awesome, :template => :foo, :description => "Description"
    # 
    # This will create a class Token::AwesomeToken, which extends {Token::Token}. After creating the 
    # class {.process_options} will be called with all provided options to apply those to the class.
    #
    # Because the options are valid for all instances of a tokenclass, the contents are stored in 
    # class-variables and class-methods are defined as accessors:
    #
    # - handler
    # - token
    # - template
    # - html
    # - area
    # - description
    #
    # Further information about this options can be found at {Token::Handler.register}
    #
    # @note Because class-methods are defined in this method, it should only be performed once!!!
    def self.process_options(options = {})
    
      # pushing defaults
      options[:template]    ||= :default
      options[:description] ||= ""
      
      options[:html]     = { 
        :class => options[:token].to_s
      }.merge(options[:html] || {})
      
      options[:area]     ||= :body      
    
      %w(handler token template html area description).each do |opt|        
        self.class_variable_set("@@#{opt}".to_sym, options[opt.to_sym])      
        
        class_eval "
          def self.#{opt}
            return self.class_variable_get(:@@#{opt}) if self.class_variable_defined? :@@#{opt}
          end
          
          def #{opt}
            self.class.#{opt}
          end
        "
      end
    end
    
    def to_s
      self.class.class_variable_get(:@@token).to_s.capitalize
    end
        
  end
end