require 'pathname' 
require Pathname.new(__FILE__).realpath + '../../lib/boot'

Configs.set :root  => Pathname.new(__FILE__).realpath + '../..'

setup_application :templates => '../templates', :output => '../out'

def load_core_doc
  Processor.process_files_to_dom 'test/js-files/core-doc.js'  
end