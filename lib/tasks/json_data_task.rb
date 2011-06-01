module Tasks

  class JsonDataTask < RenderTask

    describe     'renders all object to a json file'
    layout       nil
    
    start_method :render_json
    
    protected

    def render_json
    
      in_context Dom.root do
        
        functions = []        
        objects = []
        
        Dom.root.each_child do |child|
          if child.is_a? CodeObject::Function
            functions << {
              :name         => child.name,
              :namespace    => child.namespace,
              :constructor  => child.constructor?,
              :fullname     => child.qualified_name,
              :path         => path_to(child , :format => :html)
            }
          elsif child.is_a? CodeObject::Base
            objects << {
              :name         => child.name,
              :namespace    => child.namespace,
              :fullname     => child.qualified_name,
              :path         => path_to(child , :format => :html)
            }
          end
        end
        
        @data = {
          :functions => functions,
          :objects   => objects
        }
        
        render 'layout/json', :to_file => 'js/data.json'
      end    
    end
  end
end

Processor.register_render_task :json_data, Tasks::JsonDataTask