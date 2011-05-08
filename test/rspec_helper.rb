def should_raise(exception_type, &block)    
  begin
    block.call    
    raise RSpec::Expectations::ExpectationNotMetError
  rescue Exception => e
    e.class.should == exception_type
  end    
end
