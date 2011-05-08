# ../data.img#1771563:1
require_relative '../../lib/parser/comment'
require_relative '../../lib/code_object/function'

describe Token::Handler, "#register" do
    
  it "should add a block to the list of tokenhandlers" do  
    some_block = lambda {|token, content| puts "test" }    
    Token::Handler.register :foobar, some_block    
    Token::Handler.handlers.include?(:foobar).should == true
  end 
  
end
