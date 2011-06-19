require_relative '../renderer'
require_relative '../dom/dom'
require_relative '../helper/helper'

module Generator

  class Generator < Renderer
  
    def initialize
      super(Configs.templates + configs(:templates), configs(:layout))
      
      # include all Helpers
      Helper.constants
            .map { |c| Helper.const_get c }
            .each { |mod| extend mod if mod.is_a? Module }
            
      # Set Global Context to Dom's root node
      @_context = Dom.root
    end
    
    def perform
      
      unless self.respond_to? configs(:start_method)
        raise Exception, "#{self.class} needs to implement specified start-method '#{configs(:start_method)}'"
      end
      
      self.send configs(:start_method)
    end
    
    def context
      @_context
    end
    
    def self.description
       configs(:description)
    end
    
    # not neccesarily needed, because all Helpers are included by default
    def self.use(helper_module)
     include helper_module
    end
    
    def self.all
      # Otherwise we don't get the global Generator-Module
      gen_module = Object.const_get(:Generator)
      gen_module.constants
                .map { |c| gen_module.const_get c }
                .select { |klass| klass.class == Class and klass.superclass == self }
    end
    
    protected
    
    # @group Generator-Specification methods
    
    def self.describe(desc)
      self.set_config(:description, desc.to_s)
    end
  
    def self.layout(layout_view)    
      unless layout_view.nil?
        self.set_config(:layout, 'layout/' + layout_view)
      else
        self.set_config(:layout, nil)
      end
    end
  
    def self.templates(path_to_templates)
      self.set_config(:templates, path_to_templates)
    end  
    
    def self.start_method(method)
      self.set_config(:start_method, method.to_sym)
    end
    
    
    # @group helper methods to make usage of class-variables work in **inheriting** classes
    
    def self.configs(attribute)
    
      key = "@@_configs_#{attribute.to_s}".to_sym
      
      defaults = {:templates    => '/views',
                  :layout       => nil,
                  :description  => 'No description given.',
                  :start_method => :perform_task }
      
      if self.class_variable_defined? key
        self.class_variable_get(key)
      else
        defaults[attribute.to_sym]
      end    
    end
    
    # the instance equivalent to get the class-variable of the **inheriting** class
    def configs(*args)
      self.class.configs(*args)
    end
    
    def self.set_config(attribute, value)
      key = "@@_configs_#{attribute.to_s}".to_sym
      
      self.class_variable_set(key, value)
    end
    
    
    # @group context manipulation and access methods
    
    # maybe we can use this later on, while linking
    def in_context(new_context, &block)
      old_context = @_context
      @_context = new_context
      yield
      @_context = old_context
    end
    
    def context
      @_context
    end
    
    def resolve(nodename)
      @_context.resolve nodename
    end
    
  end
end