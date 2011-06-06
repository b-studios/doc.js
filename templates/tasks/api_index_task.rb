module Tasks

  class ApiIndexTask < RenderTask

    describe     'renders the api_index.html file containing all documented elements as alphabetic listing'
    layout       'application'
    
    start_method :render_api_index
    
    protected

    def render_api_index
    
      in_context Dom.root do
        @elements = []
        Dom.root.each_child do |child|
          @elements << child unless child.is_a? Dom::NoDoc
        end
        
        render 'api_index', :to_file => 'api_index.html'
      end    
    end
  end
end

Processor.register_render_task :api_index, Tasks::ApiIndexTask