require_relative '../lib/boot.rb'

Logger.setup :level => :debug

def load_core_doc
  Processor.process_files_to_dom 'test/js-files/core-doc.js'  
end