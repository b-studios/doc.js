module Token::Handler

  register :author, :area => :sidebar
  register :public, :area => :sidebar
  register :private, :area => :sidebar
  register :version, :area => :sidebar
  
  register :see, :area => :footnote

  register :deprecated, :area => :notification  
  register :todo, :area => :notification
  register :note, :area => :notification
  register :warn, :area => :notification
  
  register :example, :template => :examples, :handler => :named_multiline
   
  # Every @overload can contain **text-documentation**, **@param**- and **@return**-tokens
  #
  # It may look like:
  #
  #     @overload
  #       This is the documentation for a overload
  #       It can have multiple lines of docs
  #       
  #       @param [String] foo please notice the optional empty 
  #         line above and the linebreak of this param
  #       @return [Array] something special will be returned
  #       
  #       Followed by some more random documentation
  #
  # If no return should be possible, the more simple :named_nested_shorthand handler could be used...
  register :overload, :area => :none do |token_klass, content|  

    documentation = []
    children = []

    # First remove linebreaks with 2-times intendation
    content.gsub!(/\n((?!\n)\s){2}/, ' ')

    # Then we take every line and analyse it
    content.split(/\n/).each do |line|
    
    
      # We utilize Parser's Tokenline-Regexp here
      matches = Parser::TOKENLINE.match(line)    
      
      if matches.nil?
        documentation << line
     
      else
        name, content = matches.captures 
         
        if name == 'param'
          children << Token::Handler.apply(:typed_with_name, Token::Token::ParamToken, content)
        elsif name == 'return'
          children << Token::Handler.apply(:typed, Token::Token::ReturnToken, content)
        end
      
      end
    end
    
    self.add_token token_klass.new :content => documentation.join("\n"), :children => children, :name => self.name
  end
  
  # Example:
  #     @event MyCustomEvent
  #       This event will be triggered, if something special happens. The registered handler will be
  #       called with the following parameters:
  #       [Object] obj This object
  #       [String] msg Some message 
  register :event, :area => :body, :handler => :named_nested_shorthand
  
end
