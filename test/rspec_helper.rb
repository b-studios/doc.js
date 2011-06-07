# This is a fix, because JSON::Parser has to be registered before our Parser-Module
require 'json'

def should_raise(exception_type, &block)    
  begin
    block.call    
    raise RSpec::Expectations::ExpectationNotMetError
  rescue Exception => e
    e.class.should == exception_type
  end    
end

class Object

  def should_be_named_typed_token(name, types, content)
    self.name.should == name
    self.types.should == types
    self.content.should == content
  end
  
  def should_be_typed_token(types, content)
    self.types.should == types
    self.content.should == content
  end
  
end
