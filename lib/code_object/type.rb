require_relative 'exceptions'

module CodeObject

  module Type
  
    @@types = {}
  
    def self.register(tokenid, klass)
      @@types[tokenid.to_sym] = klass
    end
    
    def self.[](tokenid)
      @@types[tokenid.to_sym]
    end
    
    def self.include?(tokenid)
      @@types.has_key? tokenid.to_sym
    end
    
    def self.find_klass(tokenlines)
      klass = tokenlines.select {|t| self.include? t.token }
      
      if klass.size > 1
        raise CodeObject::MultipleTypeDeclarations.new, "Wrong number of TypeDeclarations: #{klass}"
      elsif klass.size == 0
        # it's not possible to create instance
        return nil
      end
      
      klass.first
    end
  end
  
end
