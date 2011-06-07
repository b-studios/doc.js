Gem::Specification.new do |s|
  s.required_rubygems_version = ">= 1.5"
  s.required_ruby_version = '>= 1.9'


  s.name = 'docjs'
  s.version = '0.1'
  s.date = '2011-06-07'
  s.summary = "Javascript Documentation Generator"
  s.description = "Create beautyful Javascript documentations with this ruby-gem. It's pretty easy to customize and add your own tokens/DSL."
  s.homepage = "https://github.com/b-studios/doc.js"
  s.authors = ["Jonathan Brachthäuser"]
  s.email = "jonathan@b-studios.de"
  s.rubyforge_project = s.name

  s.files = `git ls-files`.split("\n").find_all do |file|
    file !~ /^yard$/ && 
    file !~ /^run_tests$/ &&
    file !~/^build/ &&
    file !~/gitignore/
  end
  
  s.test_files    = `git ls-files -- {test}/*`.split("\n")

  s.executables = ['docjs']
  s.default_executable = 'bin/docjs'
  
  s.add_dependency 'rdiscount'
  s.add_dependency 'thor'

  s.require_path = 'lib'
end
