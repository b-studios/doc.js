require 'rdiscount'
require_relative 'dom/dom'
require_relative 'generator/generator'
require_relative 'document/document'

# @note The prerequisites for Processor to work is that {Logger} and {Configs} are prepared and all 
#   other components are already required. (Like the {Parser::Parser} and the {Dom}). For further
#   information about how to set up the system, see {#setup_application}.
#
# The Processor is a component, which is essential for {DocJs} to fullfil it's tasks. While {DocJs}
# serves as commandline-interface (CLI), the Processor is the heartpiece of DocJs and it's methods are
# triggered directly by DocJs after having everything set up correctly.
#
# The Processing is divided into the following stages:
module Processor 
  
  
  # @group Stage #1 - Document Processing
  
  # For each specified Markdown-Document a new instance of {Document::Document} is created and filled
  # with it's contents. Afterwards the document-nodes are added as children to `Dom.docs`.
  # 
  # ![Document Processing](img/md_process_documents.png)
  # 
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
  
  
  # @group Stage #2a - File Processing
  
  # Process JavaScript files, whose filenames are stored in `Configs.files` (After having them 
  # provided as commandline-options or in a `docjs.yml`-file)
  # 
  # Parses each JavaScript file and collects the found comments. After parsing everything all comments
  # are returned as an Array.
  #
  #     [ *.js Files ] --(parses)--> [ Comments ]
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
  
  
  # @group Stage #2b - Comment Processing
  
  # Processing comment-stream and convert to {CodeObject CodeObjects}
  # This stage also adds the CodeObjects to {Dom}.
  #
  #     [ Comments ] --(converts to)--> [ CodeObject ] --(add to)--> [ Dom ]
  def self.process_comments(comments)
    
    comments = [comments] unless comments.is_a? Array
    
    comments.each do |comment|    
      code_object = comment.to_code_object                                # convert to code_object
      Logger.debug "Adding to Dom: #{code_object}"
      Dom.add_node(code_object.path, code_object) unless code_object.nil? # add to dom
    end
  end  
  
  # @group Stage #3 - Template Processing  

  # Searches for all Generator-Classes, instantiates them and calls {Generator::Generator#perform} 
  # to trigger the content-generation.
  #
  #     [ Generators ] --(uses)--> [ Dom ]
  #            |
  #            ---(generates)--> [ HTML-Output ]
  def self.start_generators
    Generator::Generator.all.each { |task| task.new.perform }
  end
 
 
  # @group Combined Stages
  
  # Combines Stages {.parse_files #2a}, {.process_comments #2b} and {.start_generators #3}
  def self.process_and_render
    process_files_to_dom
    start_generators
  end
  
  # Combines Stage {.parse_files #2a} and {.process_comments #2b}
  def self.process_files_to_dom(files = nil)
    process_comments parse_files(files)
  end
end