require 'erb'
require 'fileutils'

# The Renderer is the heart-piece of each {Generator::Generator}, but can also be used without them.
# It uses ERB-Templates, which are being rendered with a binding to the Renderer-instance.
#
# It's only method {#render} can be used in multiple ways, which are explained {#render here}.
# The Renderer is automatically been set up by the Generator, but to understand how it works we
# may setup it ourselves like:
#
#     my_renderer = Renderer.new 'my/template/path', 'layout/application'
#     my_renderer.render 'test', :to_file => 'output.html'
#
# This will render the template `my/template/path/test.html.erb` in the layout 
# `my/template/path/layout/application.html.erb` and saved to `output.html`.
#
# Most of the time, as with Generators, the renderer will be extended and used like:
#
#     class MyRenderer < Renderer
#  
#        def initialize
#          super('my/template/path', 'layout/application')
#        end
#
#        def index
#          render 'test', :to_file => 'output.html'
#        end
#      end
class Renderer

  def initialize(default_path, layout)
    @_path = default_path
    @_layout = layout
  end

  # @overload render(template, *opts)
  #   Options **opts**:
  #   
  #   - :layout (String) Default is specified in constructor. For example `'json'` or `'application'`
  #   - :to_file (String) Optional file-path to save the output to.   
  #   
  #   @param [String, Symbol] template Template-file **without** file-extension. (Like `index` => `index.html.erb`)
  #   @param [Hash] opts
  #   @return [String, nil] the rendered output
  #
  #
  # @overload render(:partial => template, :collection => [...])
  #   For each item of `collection`, the partial will be rendered once. The output consists of all
  #   those concatenated render-passes.
  #   The value of each item will be bound to a local-variable called like the partial, without leading
  #   _. (i.e. if partial-name = "_test.html.erb" the variable is called `test`
  #     
  #   Options **opts**:
  #   
  #   - :template (String, Symbol) Template-file **without** file-extension. (Like `index` => `index.html.erb`)
  #   - :collection (Array)
  #   
  #   @param [Hash] opts
  #   @return [String] the rendered output
  #
  #
  # @overload render(:partial => template, :locals => {...})
  #   Each key of `locals` will be set to it's value in the local-binding of the partial.
  #    
  #   Options **opts**:
  #
  #   - :template (String, Symbol) Template-file **without** file-extension. (Like `index` => `index.html.erb`)
  #   - :locals (Hash) Hash of variables, which will be available via local-variables in the partial-binding    
  #   
  #   @param [Hash] opts
  #   @return [String] the rendered output
  #
  #
  # @example simple rendering
  #   render 'test', :layout => nil #=> returns a string, containing the rendered template 'test.html.erb'
  #
  # @example rendering within a layout
  #   # layout/app.html.erb
  #   <html>
  #      <%= yield %>
  #   </html>
  #   
  #   # MyCustomRenderer < Renderer
  #   render 'test', :layout => 'layout/app' #=> renders 'test.html.erb' within 'app.html.erb'
  #
  # @example rendering a partial with collections
  #   # _item.html.erb
  #   <li><%= item %></li>   
  #
  #   # my_view.html.erb
  #   <ul>
  #     <%= render :partial => 'item', :collection => ["Foo", "Bar", "Baz"]
  #   </ul>
  #   
  #   #=> <ul><li>Foo</li><li>Bar</li><li>Baz</li></ul>
  #
  # @example setting local-variables within a partial
  #   # _item.html.erb
  #   <strong><%= foo %></strong> <em><%= bar %></em>
  #
  #   # my_view.html.erb
  #   <%= render :partial => 'item', :locals => { :foo => "Hello", :bar => "World" } %>
  #   
  #   #=> <strong>Hello</strong> <em>World</em>
  #
  # @example rendering to file
  #   render 'my_test', :to_file => "test_output.html"
  #
  # @note Pretty much inspired by Ruby on Rails
  # @see http://guides.rubyonrails.org/layouts_and_rendering.html
  def render(opt = nil, extra_options = {})

    # Prepare Options
    if opt.nil?
      opt = { :layout => @_layout }

    elsif opt.is_a?(String) || opt.is_a?(Symbol)
      extra_options[:template] = opt
      extra_options[:layout] ||= @_layout
      opt = extra_options

    elsif !opt.is_a?(Hash)
      extra_options[:partial] = opt
      opt = extra_options
    end

    if opt[:partial]
      render_partial opt
      
    else    
      # bind @current_path correctly to use in helpers and views
      if opt[:to_file]
        # Make absolute
        opt[:to_file] = File.expand_path(opt[:to_file], Configs.output)        
        @current_path = File.dirname opt[:to_file]
      else
        @current_path ||= Configs.output
      end

      # render 'view_name', :option1 => 1, :option2 => 2
      template = path_to_template opt[:template]
      begin
        view = ERB.new(File.read template).result(binding)
      rescue Exception => e
        raise "Error while rendering #{template}\n#{e.message}"
      end

      
      # then render with layout
      if opt[:layout]
        layout = File.read path_to_template opt[:layout]
        view = render_in_layout(layout) { view }
      end

      # Render to file, if desired
      if opt[:to_file]
        # create directories recursive
        FileUtils.mkpath File.dirname opt[:to_file]

        # Working with Thor-Actions would be nice, but it seems to be too much overhead for this small
        # renderer
        File.open(opt[:to_file], "w+") do |f|
          f.write view
        end
      else        
        return view
      end
    end
 
  end

  protected

  def render_in_layout(layout, &view)
    ERB.new(layout).result(binding)
  end

  def path_to_template(file)
    File.expand_path "#{file}.html.erb", @_path
  end

  def render_partial(opt)
  
    # add underscore to last element of foo/bar/baz
    parts = opt[:partial].split('/')
    parts[-1] = "_"+parts.last        
    
    template = path_to_template(parts.join('/'))
    
    begin
      template_source = File.read(template)
    rescue Exception
      raise "Could not find Partial '#{template}'"
    end 
    
    if opt[:collection]

      partial_name = opt[:partial].split('/').last
      
      # Render it!
      begin          
        opt[:collection].map { |item|
          define_singleton_method(partial_name) { item }
          ERB.new(template_source).result(binding)
        }.join "\n"
      rescue Exception => e
        raise "Error while rendering #{partial_name}\n#{e.message}"
      end
    
    # It's not a collection  
    else

      # If there are locals we have to save our instance binding, otherwise we will store our
      # newly created local-variables in the blockcontext of each_pair
      # values has to be defined explicitly to be overridden by the block and still available inside of eval
      if opt[:locals]
        value = nil
        instance_context = binding
        opt[:locals].each_pair do |local, value|
          Logger.warn("Please change your partial-name or local binding, because #{local} is already set in this context.") if respond_to? local
          define_singleton_method(local) { value }
        end
      end
      
      begin
        ERB.new(template_source).result(binding)
      rescue Exception => e
        raise "Error while rendering #{template}\n#{e.message}"
      end
    end
  end

end