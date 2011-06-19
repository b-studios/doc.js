module Generator

  class JsonGenerator < Generator

    describe     'renders all documented objects to a json file. Objects and Functions are handled seperatly'
    layout       nil
    
    start_method :render_json
    
    protected

    def render_json
    
      in_context Dom.root do
        
        functions = []        
        objects = []
        
        Dom.root.each_child do |child|
        
          code_object = {
              :namespace    => child.namespace,
              :fullname     => child.qualified_name,
              :path         => path_to(child , :format => :html)
          }
        
          # it's a root level element
          if child.namespace.nil? or child.namespace == ""
            code_object[:name] = child.name            
          else
            code_object[:name] = '.'+child.name        
          end
        
          if child.is_a? CodeObject::Function
            functions << code_object.merge({
              :constructor  => child.constructor?              
            })
          elsif child.is_a? CodeObject::Base
            objects << code_object
          end
        end
        
        @varname = 'apisearch'
        @data = {
          :functions => functions.sort {|a,b| a[:name] <=> b[:name] },
          :objects   => objects.sort {|a,b| a[:name] <=> b[:name] }
        }
        
        render 'layout/json', :to_file => 'js/apisearch-data.js'
      end    
    end
  end
end