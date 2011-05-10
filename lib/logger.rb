# The logger is using colorizing-functionality from Thor's shell
# Therefore on initialization it requires the current Thor-Application Object.
module Logger
  
  LogLevel = Struct.new :numeric, :prefix, :color
  
  LEVEL = {
    :debug  => LogLevel.new(0,  "DEBUG ", :white),
    :info   => LogLevel.new(1,  "INFO  ", :blue),
    :warn   => LogLevel.new(2,  "WARN  ", :yellow),
    :error  => LogLevel.new(3,  "ERROR ", :red),
    :system => LogLevel.new(10, "",       :black)
  }
   
  def self.setup(thor_shell, args = {})
    @@shell = thor_shell
    @@logfile = args[:file]        || "logfile.log"
    @@level   = LEVEL[args[:level] || :info]
    
    # write start sequence
    log LEVEL[:system], ["\n\n== #{Time.now} #{'='*50}"]
  end

  def self.method_missing(name, *args)
    level = LEVEL[name.to_sym]    
    raise NoMethodError.new(name.to_s) if level.nil?
    
    log(level, args)
  end
  
  protected
  
  def self.log(level, msg)
    return if level.numeric < @@level.numeric
    
    msg = msg.join "\n"
    
    File.open(@@logfile, "a") do |f|
      f.write "#{level.prefix} #{msg}\n"
    end
    
    @@shell.say @@shell.set_color(level.prefix, level.color, true) +  msg
  end

end
