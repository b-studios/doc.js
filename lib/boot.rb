require 'thor'
require 'yaml'
require 'json'

require_relative 'thor'
require_relative 'logger'
require_relative 'configs'
require_relative 'parser/parser'
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