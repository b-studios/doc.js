module Configs

  def self.set(sym_or_hash, value = nil)

    unless sym_or_hash.is_a? Hash
      sym_or_hash = { sym_or_hash => value }  
    end

    sym_or_hash.each_pair do |attr, value|
      set_attribute(attr, value)
    end
  end

  def self.attributes
    class_variables.map do |var|
      var.to_s.scan(/@@(.*)/).first.first.to_sym
    end
  end
  
  def self.method_missing(method_name, *args)
    nil
  end

  protected

  def self.set_attribute(key, value)

    key = key.to_s

    class_variable_set("@@#{key}", value)

    class_eval <<-EOS
      def self.#{key}
        return @@#{key}
      end
    EOS
    
    if value.is_a? TrueClass or value.is_a? FalseClass
      class_eval <<-EOS
        def self.#{key}?
          return @@#{key}
        end
      EOS
    end
  end

end
