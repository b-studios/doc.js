require "thor"
#!/usr/bin/ruby1.9

require_relative 'lib/thor'
require_relative 'lib/logger'
require_relative 'lib/configs'
require_relative 'lib/parser/parser'
require_relative 'lib/code_object/function'
require_relative 'lib/dom/dom'
require_relative 'lib/renderer/controller'
require_relative 'lib/processor'

# @todo The general flow of information should be documented here
# 
# --String--> [Parser] --Commentstream--> [CodeObjectFactory] --Objectstream--> [Registry]
#
# Parser
# ------
# Turns the incoming stream of characters (string) into a stream of 
# {Parser::Comment comments}. Those comments contain the parsed doclines, which
# are simply all lines found in the comment and all tokenlines. 

# configure approot
Configs.set :root  => Pathname.new(__FILE__).realpath + '..'

# Pipeline:
#   1. load options from shell and specified YAML-file (if any)
#   2. load files
#   3. parse files
#   4. turn into objects and save to dom
#   5. render templates
#
# @note options declared in a build.yml will override command-line ones
# @todo command line option to copy all templates to specified directory like
#   jsdoc dump_templates ../templates/original
class JsDoc < Thor
    
  include Thor::Actions
    
  desc "jsdoc", "Starts documentation process"
  set_options :files =>
                  { :type => :array,  :aliases => '-f', :default => [], :required => true },
  
              :output =>
                  { :type => :string, :aliases => '-o', :default => 'out' },
                  
              :templates =>
                  { :type => :string, :aliases => '-t', :default => Configs.root + 'templates' },
                  
              :logfile =>
                  { :type => :string, :aliases => '-lf', :default => 'jsdoc.log' },
                  
              :loglevel =>
                  { :type => :string, :aliases => '-ll', :default => 'info' }
  
  def jsdoc(config_file = nil)
    # @see Thor#merge_options
    configs = config_file ? merge_options(options, config_file) : options
    
    begin
      setup_application configs
      parse_files    
      render_dom      
      Logger.info "Copying template resources to output"
      directory 'static', '.' # copy resources
            
    rescue Exception => error
      Logger.error error
    end    
  end  
  
  protected
  
  def setup_application(options)
        
    # initialize Logger
    Logger.setup self.shell,
                 :logfile => File.expand_path(options[:logfile], Dir.pwd),
                 :level   => options[:loglevel].to_sym
    
    Logger.info "Setting up Application"
    
    # Process option-values and store them in our Configs-object
    Configs.set :options      => options, # Just store the options for now
                :wdir         => Dir.pwd, # The current working directory
                :output       => File.absolute_path(options[:output]),
                :templates    => File.absolute_path(options[:templates]),
                :files        => options[:files]
                
    
    # Config Thor settings
    JsDoc.source_root(Configs.templates)
    self.destination_root = Configs.output
    
    Logger.debug "Given options: #{options}"
    Logger.debug "App Root: #{Configs.root}"
    Logger.debug "Working Dir: #{Configs.wdir}"
    Logger.debug "Output Dir: #{Configs.output}"
  end
  
  def parse_files
        
    return if Configs.files.nil?      
    
    Configs.files.each do |file|  
      Logger.info "Processing file #{file}"      
      Processor.process_file(file)     
    end
  end
  
  def render_dom
    @controller = Controller.new(Configs.templates, 'layout/application')
    @controller.render_nodes(Dom)
  end  
  
end

unless ARGV.first and JsDoc.method_defined?(ARGV.first)
  ARGV.unshift 'jsdoc'
end
JsDoc.start(ARGV)
