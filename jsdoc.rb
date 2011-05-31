#!/usr/bin/ruby1.9
require_relative 'lib/boot'

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
               
              :docs =>
                  { :type => :array,  :aliases => '-d', :default => ['README.md'], :required => true },
  
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
      
      # Config Thor settings
      JsDoc.source_root(Configs.templates)
      self.destination_root = Configs.output
      
      Processor.prepare_documents
      # let's check our Documents tree
      Dom.docs.print_tree
      
      # the configs are now available through our Configs-module      
      Processor.process_and_render
        
      Logger.info "Copying template resources to output"
      directory 'static', '.' # copy resources
            
    rescue Exception => error
      Logger.error error.message + "\n" + error.backtrace.map{|l| "  #{l}" }.join("\n")
    end    
  end  
    
  desc "tokens", "Lists all supported tokens"
  def tokens
    say "Supported tokens:"
    say Token::Handler.handlers.map{|k,v| "  @#{k}" }.sort.join "\n"    
  end
  
  desc "tasks", "Lists all registered render-tasks"
  def tasks
    say "Registered render-tasks:"
    
    task_table = Processor.render_tasks.map{|k,v| [":#{k}","# #{v.description}"] }.sort
    
    print_table task_table, :ident => 2, :colwidth => 20    
  end  
end

unless ARGV.first and JsDoc.method_defined?(ARGV.first)
  ARGV.unshift 'jsdoc'
end
JsDoc.start(ARGV)