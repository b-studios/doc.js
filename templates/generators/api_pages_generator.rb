module Generator

  class ApiPagesGenerator < Generator

    describe     'renders documented objects type-dependant (Functions and Objects)'
    layout       'application'
    
    start_method :render_objects
    
    protected

    def render_objects
      Dom.root.each_child do |node| 
        next if node.is_a? Dom::NoDoc 
        
        if node.is_a? CodeObject::Function
          render_function node
        else
          render_object node
        end
      end
    end

    def render_object(code_object)       
    
      Logger.info "Rendering CodeObject '#{code_object.name}'"
      
      in_context code_object do
        @object = code_object
        @methods = @object.children.values.select {|c| c.is_a? CodeObject::Function }
        @children = @object.children.values - @methods
        render 'object/index', :to_file => path_to(code_object, :format => :html)
      end
    end
    
    def render_function(code_object)
      Logger.info "Rendering Function '#{code_object.name}'"
      
      in_context code_object do
        @function = code_object
        @prototype = code_object.prototype
        @methods = @function.children.values.select {|c| c.is_a? CodeObject::Function }
        render 'function/index', :to_file => path_to(code_object, :format => :html)
      end
    end    
  end
end