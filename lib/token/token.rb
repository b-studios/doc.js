module Token
  class Token

    attr_reader :name, :content, :types, :children
    
    def initialize(args = {})
    
      @name = args[:name]
      @types = args[:types]
      @children = args[:children]      
      @content = args[:content] || ""
    end    
    
  end
end