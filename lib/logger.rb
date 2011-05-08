module Logger

  LEVEL = {
    :debug => 0,
    :info => 1,
    :warn => 2,
    :error => 3
  }
 
  def self.setup(args = {})
    @@logfile = args[:file]        || "logfile.log"
    @@level   = LEVEL[args[:level] || :info]
    
    # write start sequence
    log 10, ["\n\n-- #{Time.now} #{'-'*50}"]
  end

  def self.method_missing(name, *args)
    level = LEVEL[name.to_sym]    
    raise NoMethodError.new(name.to_s) if level.nil?
    
    log(level, args)
  end
  
  protected
  
  def self.log(level, msg)
    return if level < @@level
    
    msg = msg.join "\n"
    
    File.open(@@logfile, "a") do |f|
      f.write "\n" + msg
    end
    
    puts msg
  end

end
