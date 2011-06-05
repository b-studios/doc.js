module Token
  class Token

    attr_reader :name, :content, :types, :children
    
    def initialize(args = {})
    
      @name = args[:name]
      @types = args[:types]
      @children = args[:children]      
      @content = args[:content] || ""
    end    
    
    def self.handler      
      self.class_variable_get(:@@handler) if self.class_variable_defined? :@@handler
    end
    
    def handler
      self.class.handler
    end
        
    def self.token
      self.class_variable_get(:@@token) if self.class_variable_defined? :@@token
    end    
    
    def token
      self.class.token
    end    
    
  end
end