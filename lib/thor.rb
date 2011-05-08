class Thor

  protected

  # @param [Hash<Hash>] options
  def self.set_options(options)    
    options.each {|name, hash| method_option(name, hash) }    
  end

  # Types
  # :boolean - is parsed as --option or --option=true
  # :string - is parsed as --option=VALUE
  # :numeric - is parsed as --option=N
  # :array - is parsed as --option=one two three
  # :hash - is parsed as --option=name:string age:integer
  #
  # @note options declared in a build.yml will override command-line ones
  # @return [Hash] options
  def merge_options(options, filename)
    require 'yaml' # only load yaml if we are reading from file
    configs = YAML.load_file(filename)
    merged = {}
    options.each { |name, value| merged[name.to_sym] = configs[name] || value }
    merged
  end

end
