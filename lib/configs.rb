# Systemwide Singleton, which can be used to store global configurations, like paths or some other
# settings
#
# @example Usage
#   Configs.set :foo, 123
#   Configs.foo #=> 123
#   
#   Configs.set :foo => 456, :bar => "Hello World"
#   Configs.foo #=> 456
#   Configs.bar #=> "Hello World"
#   
#   Configs.baz #=> nil
#
# @example List all configs
#   Configs.attributes #=> { :foo => 456, :bar => "Hello World" }
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
  
  def self.clear
    class_variables.each do |var|
      class_variable_set(var, nil)
    end
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
