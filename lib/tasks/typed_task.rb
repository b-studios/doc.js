module Tasks

  class TypedTask < RenderTask

    describe     'renders objects type-dependant'
    layout       'application'
    
    start_method :render_object_recursive
    
    protected

    # @todo switch on registered Types to enable dynamic view-changing
    def render_object_recursive(code_object = Dom.root)
      
      unless code_object.is_a? Dom::NoDoc  
        Logger.info "Rendering CodeObject '#{code_object.name}'"
        
        @object = code_object
        @methods = @object.children.values.select {|c| c.is_a? CodeObject::Function }
        @children = @object.children.values - @methods
        
        # Render has to be documented very well, because it will be used in RenderTasks
        render 'object/index', :to_file => code_object.file_path + '.html'
      end
      
      code_object.children.values.each {|child| render_object_recursive(child) }
    end
  end
end

Processor.register_render_task :typed, Tasks::TypedTask