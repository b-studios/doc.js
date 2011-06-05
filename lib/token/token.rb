module Token
  class Token

    attr_reader :name, :content, :types, :children
    
    def initialize(args = {})
    
      @name = args[:name]
      @types = args[:types]
      @children = args[:children]      
      @content = args[:content] || ""
    end    
    
    # @note should only be performed once!!!
    def self.process_options(options = {})
    
      # pushing defaults
      options[:template] ||= :default
      
      options[:html]     = { 
        :class => options[:token] 
      }.merge(options[:html] || {})
      
      options[:area]     ||= :none      
    
      %w(handler token template html area).each do |opt|        
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