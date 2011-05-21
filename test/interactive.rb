require_relative '../lib/thor'
require_relative '../lib/logger'
require_relative '../lib/configs'
require_relative '../lib/parser/parser'
require_relative '../lib/code_object/function'
require_relative '../lib/dom/dom'
require_relative '../lib/processor'

def get_objects_from_file(filename)
  Processor.process_file File.expand_path(filename, __FILE__)
end
