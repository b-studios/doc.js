require_relative '../renderer'
require_relative '../dom/dom'
require_relative '../helper/helper'

module Tasks

  class RenderTask < Renderer
  
    include Helper::Helper
  
    # Default Config-Values
    @@configs = {
        :templates    => '',
        :layout       => nil,
        :description  => 'No description given.',
        :start_method => :perform_task
    }
    
    def initialize
      super(Configs.templates + @@configs[:templates], @@configs[:layout])
      
      # Set Global Context to Dom's root node
      @_context = Dom.root
    end
    
    def perform
      
      unless self.respond_to? @@configs[:start_method]
        raise Exception, "#{self.class} needs to implement specified start-method '#{@@configs[:start_method]}'"
      end
      
      self.send @@configs[:start_method]
    end
    
    def self.description
      @@configs[:description]
    end
        
    protected
    
    def self.describe(desc)
      @@configs[:description] = desc.to_s
    end
  
    def self.layout(layout_view)    
      @@configs[:layout] = 'layout/' + layout_view
    end
  
    def self.templates(path_to_templates)
      @@configs[:templates] = path_to_templates
    end  
    
    def self.start_method(method)
      @@configs[:start_method] = method.to_sym
    end
    
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