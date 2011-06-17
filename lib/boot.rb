require 'thor'
require 'yaml'
require 'json'

require_relative 'thor'
require_relative 'logger'
require_relative 'configs'
require_relative 'parser/parser'
require_relative 'token/handler'
require_relative 'code_object/function'
require_relative 'dom/dom'
require_relative 'processor'

def setup_application(options = {})
        
  # initialize Logger
  Logger.setup :logfile => (options[:logfile] && File.expand_path(options[:logfile], Dir.pwd)),
               :level   => (options[:loglevel] || :info).to_sym
  
  Logger.info "Setting up Application"
  
  # Process option-values and store them in our Configs-object
  Configs.set :options      => options, # Just store the options for now
              :wdir         => Dir.pwd, # The current working directory
              :output       => File.absolute_path(options[:output]),
              :templates    => File.absolute_path(options[:templates]),
              :includes     => (options[:includes] && File.absolute_path(options[:includes])),
              :files        => (options[:files] && options[:files].map {|path| Dir.glob(path) }.flatten),
              :docs         => (options[:docs] && options[:docs].map {|path| Dir.glob(path) }.flatten)
  
  Logger.debug "Given options: #{options}"
  Logger.debug "App Root:      #{Configs.root}"
  Logger.debug "Working Dir:   #{Configs.wdir}"
  Logger.debug "Output Dir:    #{Configs.output}"
  Logger.debug "Template Dir:  #{Configs.templates}"
end

def load_templates(template_path = nil)

  if template_path.nil? and Configs.templates
    template_path = Configs.templates
  
  elsif template_path.nil?
     template_path =( Configs.root + 'templates').to_path
  
  else
    template_path = File.absolute_path(template_path)
  end
  
  require template_path + '/application.rb'
  
  # After loading all template files, we can include our default-template-helper
  Tasks::RenderTask.use Helper::Template if Helper.const_defined? :Template
   
end