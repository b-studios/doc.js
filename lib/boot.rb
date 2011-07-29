require 'thor'
require 'yaml'
require 'json'

require_relative 'thor'
require_relative 'logger'
require_relative 'configs'
require_relative 'parser/parser'
require_relative 'token/handler'
require_relative 'code_object/base'
require_relative 'dom/dom'
require_relative 'processor'

# `#setup_application` is called during the initialization process of DocJs within {DocJs#docjs}
#
# ![Boot Activity Diagram](img/md_boot.svg)
#
# It is responsible to configure the two application-wide Singleton Objects {Logger} and {Configs}
# and fill {Configs} with the given commandline arguments.
#
# If the user is using it's own custom templates (see {file:CUSTOMIZE.md}) those templates will be
# included before the processing can begin.
def setup_application(options = {})
        
  # Initialize Logger
  Logger.setup :logfile => (options[:logfile] && File.expand_path(options[:logfile], Dir.pwd)),
               :level   => (options[:loglevel] || :info).to_sym
  
  Logger.info "Setting up Application"
  
  # Process option-values and store them in our Configs-object
  Configs.set :options      => options, # Just store the options for now
  
              # Set the paths  
              :wdir         => Dir.pwd, # The current working directory
              :output       => File.absolute_path(options[:output]),
              :templates    => File.absolute_path(options[:templates]),
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
end