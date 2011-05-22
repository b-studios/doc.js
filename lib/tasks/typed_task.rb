module Tasks

  class TypedTask < RenderTask

    describe     'renders objects type-dependant'
    layout       'application'
    
    start_method :render_objects
    
    protected

    def render_objects
      Dom.root.each_child { |o| render_object o }
    end

    # @todo switch on registered Types to enable dynamic view-changing
    def render_object(code_object)
      return if code_object.is_a? Dom::NoDoc  
    
      Logger.info "Rendering CodeObject '#{code_object.name}'"
      
      in_context code_object do
        @object = code_object
        @methods = @object.children.values.select {|c| c.is_a? CodeObject::Function }
        @children = @object.children.values - @methods
        
        # Render has to be documented very well, because it will be used in RenderTasks
        render 'object/index', :to_file => path_to(code_object, :format => :html)
      end
    end
  end
end

Processor.register_render_task :typed, Tasks::TypedTask