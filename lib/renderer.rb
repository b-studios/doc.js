# ../data.img#1783836:1
require 'erb'
require 'fileutils'

class Renderer

  def initialize(default_path, layout)
    @_path = default_path
    @_layout = layout
  end

  # Teilweise aus rails...
  # @todo better error-handling with partial and layout context information!!!
  def render(opt = nil, extra_options = {})

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
    
      # add underscore to last element of foo/bar/baz
      parts = opt[:partial].split('/')
      parts[-1] = "_"+parts.last        
      
      begin
        template_file = File.read path_to_template(parts.join('/'))
      rescue Exception
        raise "Could not find Partial '#{opt[:partial]}'"
      end
      if opt[:collection]

        partial_name = opt[:partial].split('/').last

        opt[:collection].map { |item|
          define_singleton_method(partial_name) { item }
          ERB.new(template_file).result(binding)
        }.join "\n"
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

        ERB.new(template_file).result(binding)
      end
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
      view = ERB.new(File.read path_to_template opt[:template]).result(binding)
      
      # then render with layout
      if opt[:layout]
        layout = File.read path_to_template opt[:layout]
        view = render_in_layout(layout) { view }
      end

      # Render to file, if desired
      if opt[:to_file]
        # create directories recursive
        FileUtils.mkpath File.dirname opt[:to_file]

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

end