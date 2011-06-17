require 'rdiscount'
require_relative 'dom/dom'
require_relative 'tasks/render_task'
require_relative 'document/document'

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
  
  def self.process_files_to_dom(files = nil)
    process_comments parse_files(files)
  end 
  
  # @group Stage #1 - FileProcessor
  
  # Parsing Files and creating comment stream
  def self.parse_files(files = nil)
    files ||= Configs.files
        
    return if files.nil?    

    files = [files] unless files.is_a? Array
    comments = []
    
    files.each do |file|  
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
  def self.perform_all_tasks
    Tasks::RenderTask.all.each { |task| task.new.perform }
  end
  
  # @group Stage #4 - Document Processor
    
  def self.prepare_documents
    # underscores will be replaced with whitespaces as title
    Configs.docs.each do |doc|
    
      doc_path = File.expand_path(doc, Configs.wdir)    
      Logger.debug "Working with Document #{doc_path}"
      
      contents = File.read(doc_path)
      
      # Those documents get registered in a special {Dom::Node} Dom.docs
      document = Document::Document.new(doc_path, contents)
      Dom.docs.add_node(document.path, document)
      
      # The docs can be accessed via Dom later on
    end
  end
 
end