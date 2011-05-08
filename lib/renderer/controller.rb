# ../data.img#1800238:1
require_relative 'renderer'

class Controller < Renderer::Renderer
  
  def initialize(*args)
    super(*args)
    @current_path = Configs.output
  end
  
  def render_nodes(code_object)
  
    Logger.debug "rendering node of #{code_object}"

    code_object.children.each do |name, node|
      render_object(node) unless node.is_a? Dom::NoDoc      
      render_nodes(node)
    end
  end
  
  
  # @todo switch on registered Types to enable dynamic view-changing
  def render_object(code_object)
    
    Logger.debug "rendering object #{code_object}"
        
    @object = code_object
    @methods = @object.children.values.select {|c| c.is_a? CodeObject::Function }
    @children = @object.children.values - @methods
    render 'object/index', :to_file => code_object.file_path + '.html'
  end
  
end
