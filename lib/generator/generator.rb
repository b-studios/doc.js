require_relative '../renderer'
require_relative '../dom/dom'
require_relative '../helper/helper'

module Generator

  # If you already familiar with Ruby on Rails: Generators are pretty much like Controllers in Rails.
  # That's like in Rails:
  #
  # - They use the existing data-model (The {Dom} in our case)
  # - They start the rendering process in a view, by calling {Renderer#render render}.
  # - If you want to make use of data in a view, you can store it in an instance-variable, like `@nodes`
  # - Helpers are included in the generator, so you can utilize their messages in views
  #
  # The major difference between controllers in Rails and generators in DocJs is, that DocJs triggers
  # all generators one after another and there is no real interaction between the views and the
  # generator.
  #
  # In other words, after collecting all necessary informations about the JavaScript-Files and
  # Markdown-Documents DocJs uses the Generators to create the final output.
  #
  # @example a simple generator
  #   module Generator
  #     class MyTestGenerator < Generator
  #       # For more information about those methods, see section Generator-Specification methods
  #       describe     'does awesome things'
  #       layout       'application'
  #       start_method :go
  #       templates    '/views/special_ones'
  #        
  #       protected
  #
  #       def go       
  #         in_context Dom.root do
  #           @elements = []
  #           Dom.root.each_child do |child|
  #             @elements << child unless child.is_a? Dom::NoDoc
  #           end
  #           
  #           render 'my_view', :to_file => 'output_file.html'
  #         end    
  #       end
  #     end
  #   end
  #
  # The following image should help you to get a general overview, how the components of DocJs interact:
  #
  # ![Render Flow](../img/md_render_flow.png)
  #
  # One may notice, that {Renderer} and {Generator::Generator} are not that separable, as shown in this
  # image. In fact the concrete Generator (like {Generator::ApiIndexGenerator}) inherits from 
  # {Generator::Generator}, which in turn inherits from {Renderer}.
  # So we've got an inheritence-chain like:
  #
  #     Generator::ApiIndexGenerator < Generator::Generator < Renderer
  #
  # Helpers
  # -------
  # You can create your own helper functions, bundled in a custom helper-module. They automatically
  # will be mixed in all Generators, as long as they match the following conditions:
  #
  # - Your module has to be a Submodule of Helper
  # - Your code has to be included somewhere (i.e. `require 'my_helper'` in `application.rb`)
  # 
  # For example your helper could look like:
  # 
  #     # TEMPLATE_PATH/helpers/my_helper.rb
  #     module Helper::MyHelper       
  #       def my_greeter
  #         "Hello Woooorld"
  #       end       
  #     end
  #     
  #     # TEMPLATE_PATH/application.rb
  #     require_relative 'helpers/my_helper'
  #
  # Then you could use them in your Generator or in your Views
  #
  #     # TEMPLATE_PATH/views/template.html.erb
  #     <h1><%= my_greeter %></h1>
  class Generator < Renderer
  
    def initialize
      # At this point we pass the configurations to our Parent `Renderer`
      super(Configs.templates + configs(:templates), configs(:layout))
      
      # include all Helpers
      Helper.constants
            .map { |c| Helper.const_get c }
            .each { |mod| extend mod if mod.is_a? Module }
            
      # Set Global Context to Dom's root node
      @_context = Dom.root
    end
    
    # @group Generator-Specification methods
    
    # This description is used in the cli-command `docjs generators` to list all generators and their
    # descriptions
    #
    # @param [String] desc A short description of this generators task
    def self.describe(desc)
      self.set_config(:description, desc.to_s)
    end
  
    # Specifies which layout should be used to render in (Default is `nil`)
    #
    # @param [String] layout_view
    def self.layout(layout_view)    
      unless layout_view.nil?
        self.set_config(:layout, 'layout/' + layout_view)
      else
        self.set_config(:layout, nil)
      end
    end
  
    # Which method should be invoked, if generator is executed (Default is `:index`)
    #
    # @param [String, Symbol] method
    def self.start_method(method)
      self.set_config(:start_method, method.to_sym)
    end
     
    # The path to your views (Default is `/views`)
    #
    # You can use this method, to specify a special template path, for example if you want to use
    # a subdirectory of your views, without always having to provide the full path in all `render`-calls
    #
    # @note the layout-path is always relative to your specified path (i.e. `layout 'application'`
    #   and `templates 'my_custom'` will result in a required layout file with a path like
    #   `my_custom/layout/application.html.erb`
    #
    # @param [String] path_to_views Relative path from your scaffolded template-directory, but with 
    #   a leading `/`, like `/views/classes`
    def self.templates(path_to_views)
      self.set_config(:templates, path_to_views)
    end  
    
    # @note not neccesarily needed, because all Helpers are included by default
    #
    # Can be used to include a helper in a Generator 
    def self.use(helper_module)
     include helper_module
    end
    
    # @group Context manipulation- and access-methods
    
    # Modyfies the Dom-resolution-context {#context} to `new_context`, while in `&block`. After 
    # leaving the block, the context will be switched back.
    #
    # @param [Dom::Node] new_context The new context
    # @yield block The block, in which the context is valid
    def in_context(new_context, &block)
      old_context = @_context
      @_context = new_context
      yield
      @_context = old_context
    end
    
    # Retreives the current Dom-resolution-context, which can be specified by using {#in_context}
    #
    # @return [Dom::Node] the context, to which all relative nodes should be resolved
    def context
      @_context
    end
    
    # Resolves a nodename in the specified context, by using {Dom::Node#resolve} on it.
    #
    # @param [String] nodename
    # @return [Dom::Node, nil]
    # @see Dom::Node#resolve
    def resolve(nodename)
      @_context.resolve nodename
    end
    
    # @group System-Methods
    
    # Calls always the specified `:start_method` on this Generator. (Default for :start_method is
    # 'index')
    def perform
      
      unless self.respond_to? configs(:start_method)
        raise Exception, "#{self.class} needs to implement specified start-method '#{configs(:start_method)}'"
      end
      
      self.send configs(:start_method)
    end
    
    # Is used by {DocJs#generators} to provide a list of all generators and their descriptions
    #
    # @return [String] description, which has been previously entered using `.describe`
    def self.description
       configs(:description)
    end
    
    # Returns all Generators, by finding all constants in the Generator-Module and filtering them
    # for classes with parent {Generator::Generator}.
    #
    # @return [Array<Generator>]
    def self.all
      # Otherwise we don't get the global Generator-Module
      gen_module = Object.const_get(:Generator)
      gen_module.constants
                .map { |c| gen_module.const_get c }
                .select { |klass| klass.class == Class and klass.superclass == self }
    end
    
    protected
    
    # @group helper methods to make usage of class-variables work in **inheriting** classes
    
    def self.configs(attribute)
    
      key = "@@_configs_#{attribute.to_s}".to_sym
      
      defaults = {:templates    => '/views',
                  :layout       => nil,
                  :description  => 'No description given.',
                  :start_method => :index }
      
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
    
  end
end