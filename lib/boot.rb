require 'thor'
require 'json'

require_relative 'thor'
require_relative 'logger'
require_relative 'configs'
require_relative 'parser/parser'
require_relative 'code_object/function'
require_relative 'dom/dom'
require_relative 'processor'

# Load Default Tokens
require_relative 'token/tokens'

# Register Rendertasks
require_relative 'tasks/typed_task'
require_relative 'tasks/docs_task'
require_relative 'tasks/api_index_task'
require_relative 'tasks/json_data_task'

def setup_application(options)
        
  # initialize Logger
  Logger.setup :logfile => File.expand_path(options[:logfile], Dir.pwd),
               :level   => options[:loglevel].to_sym
  
  Logger.info "Setting up Application"
  
  # Process option-values and store them in our Configs-object
  Configs.set :options      => options, # Just store the options for now
              :wdir         => Dir.pwd, # The current working directory
              :output       => File.absolute_path(options[:output]),
              :templates    => File.absolute_path(options[:templates]),
              :files        => options[:files].map {|path| Dir.glob(path) }.flatten,
              :docs         => options[:docs].map {|path| Dir.glob(path) }.flatten
  
  Logger.debug "Given options: #{options}"
  Logger.debug "App Root:      #{Configs.root}"
  Logger.debug "Working Dir:   #{Configs.wdir}"
  Logger.debug "Output Dir:    #{Configs.output}"
end
