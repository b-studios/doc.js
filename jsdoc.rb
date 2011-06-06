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
    
  desc "jsdoc CONFIG_FILE", "Starts documentation process"
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
      
      # load application specific files
      require Configs.templates + '/application.rb'
      
      # Config Thor settings
      JsDoc.source_root(Configs.templates)
      self.destination_root = Configs.output
      
      Processor.prepare_documents
      # let's check our Documents tree
      Dom.docs.print_tree
      
      # the configs are now available through our Configs-module      
      Processor.process_and_render
        
      Logger.info "Copying template resources to output"
      directory 'resources/img', './img' # copy resources
      directory 'resources/css', './css'
      directory 'resources/js', './js'
            
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
  
  
  
  # @todo implement!
  desc "scaffolding OUTPUT_DIR", "You can use scaffolding to get the templates and some basic ruby-files, that you will need to create your own templates"
  set_options :logfile =>
                  { :type => :string, :aliases => '-lf', :default => 'jsdoc.log' },
                  
              :loglevel =>
                  { :type => :string, :aliases => '-ll', :default => 'info' }
  def scaffolding(output_dir)
      
    setup_application options.merge({
      :output => output_dir,
      :templates => output_dir
    })
    
    # Setup Thor paths
    JsDoc.source_root(Configs.root)
    self.destination_root = Configs.output
    
    answers = {}    
    yes_no = "(y|n)"
    
    Logger.info "We need some information from you, to customize the scaffolding process to your needs."
    
    # Some questions:
    answers[:appname] = ask "Please enter your applications name:"
    answers[:build] = yes? "Do you wan't to generate a build.yml? #{yes_no}"
    write_build_file if answers[:build]
    
    Configs.set :answers, answers
        
    # Work with the answers    
    Logger.info "Copying the template files to #{Configs.templates}"
    directory 'templates', Configs.templates    # copy templates and resources
        
    Logger.info "Copying the included *.rb files to #{Configs.includes}"    
  end
  
  
  protected
  
  def write_build_file
  
    build = {
      'files'     => [],
      'docs'      => [],
      'logfile'   => 'logfile.log',
      'loglevel'  => 'info',
      'templates' => 'templates',
      'includes'  => ['includes/*.rb']
    }
  
    say "\nPlease enter the javascript-files you want to integrate into your documentation", :bold
    say "(You will be asked multiple times, unless your answer is empty) You also can specify a file-matching pattern, docs/*.md"
    
    while true do
      answer = ask ">"
      break if answer == ""
      build['files'] << answer
    end
    
    say "\nPlease enter the markdown-documentation-files you want to integrate into your documentation", :bold
    say "(You will be asked multiple times, unless your answer is empty) You also can specify a file-matching pattern, like foo/**/*.js."
    
    while true do
      answer = ask ">"
      break if answer == ""
      build['docs'] << answer
    end
    
    # answers[:scss_build] = yes? "Do you wan't to integrate SCSS into your build-process? #{yes_no}"
    
    # maybe ask some more information to generate build.yml
    create_file Configs.wdir + "/build.yml", build.to_yaml
  end
  
end

unless ARGV.first and JsDoc.method_defined?(ARGV.first)
  ARGV.unshift 'jsdoc'
end
JsDoc.start(ARGV)