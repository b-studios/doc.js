require_relative 'renderer'
require_relative 'helper/helper'
require_relative 'dom/dom'

module Processor
  
  RenderTask = Struct.new :name, :description, :block
  @@render_tasks = {}
  
  # Accessor Method for RenderTasks
  def self.render_tasks
    @@render_tasks
  end
  
  # @group Combined Stages
  
  def self.process_and_render
    process_files_to_dom
    perform_all_tasks
  end
  
  def self.process_files_to_dom
    process_comments parse_files
  end 
  
  # @group Stage #1 - FileProcessor
  
  # Parsing Files and creating comment stream
  def self.parse_files
        
    return if Configs.files.nil?    
    
    comments = []
    
    Configs.files.each do |file|  
      Logger.info "Processing file #{file}"      
      comments += Parser::Parser.parse_file(file)
    end
    
    return comments
  end
  
  
  # @group Stage #2 - CommentProcessor
  
  # Processing comment-stream and convert to {CodeObject CodeObjects}
  # This stage also adds the CodeObjects to Dom.
  def self.process_comments(comments)
    
    comments = [comments] unless comments.is_a? Array
    
    comments.each do |comment|    
      code_object = comment.to_code_object            # convert to code_object
      Logger.debug "Adding to Dom: #{code_object}"
      Dom.add_node(code_object.path, code_object)     # add to dom
    end
  end
  
  
  # @group Stage #3 - TemplateProcessor  
  
  # just some notes
  
  # command line:
  #     $~ jsdoc render_tasks
  #     Registered Rendertasks:
  #     - typed:     renders objects type-dependant
  #     - overview:  renders an overview
  #     - files:     converts specified markdown files and renders them
  #
  
  def self.register_render_task(name, args = {}, &block)
  
    name        = name.to_sym
    templates   = args[:templates]   || ''
    layout      = args[:layout]      || nil
    description = args[:description] || 'No description given.'
    
    @@render_tasks[name] = RenderTask.new(name, description, ->{
      renderer = Renderer.new(Configs.templates + templates, layout)
      
      # prepare helpers on the fly (this way we can decide later on, which helpers to include)
      renderer.extend Helper::Helper
      
      # For blocks, which expect one parameter, we deliver our Dom
      if block.arity == 1
        renderer.instance_exec(Dom.root, &block)
      else
        renderer.instance_exec(&block)
      end
    })
    
  end

  def self.unregister_render_task(name)
    @@render_tasks.delete(name.to_sym)
  end
  
  def self.perform_all_tasks
    perform_tasks @@render_tasks.keys
  end
  
  def self.perform_tasks(tasks)
  
    tasks = [tasks] unless tasks.is_a? Array
    
    tasks.each do |task|
      task = task.to_sym
      raise Exception, "No render-task registered with name '#{task}'" unless @@render_tasks.has_key? task
      
      Logger.debug "Rendering task '#{task}'"
      @@render_tasks[task].block.call
    end
  end  
end


# @todo switch on registered Types to enable dynamic view-changing
def render_object_recursive(code_object)
  
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

Processor.register_render_task :typed,
  :description => 'renders objects type-dependant',
  :layout      => 'layout/application' do |dom|  
    render_object_recursive(dom)
  end