# ../data.img#1772235:1
require_relative '../../lib/parser/comment'
require_relative '../../lib/code_object/function'

describe Token::Container, "#process_token" do
  
  it "should add a default handler to append token to instances" do
    Token::Handler.register :some_token
    
    o1 = CodeObject::Base.new
    o1.process_token Parser::Tokenline.new :some_token, "some content"    
    o1.token(:some_token).first.content.should == "some content"
  end 

  it "should add a typed handler" do
    Token::Handler.register :some_other_token, :typed
    
    o2 = CodeObject::Base.new
    o2.process_token Parser::Tokenline.new(:some_other_token, "[Foo, Bar] some content")
    
    o2.token(:some_other_token).first.content.should == "some content"
    o2.token(:some_other_token).first.types.should == ['Foo','Bar']
  end 
  
  it "should add a typed handler" do
    Token::Handler.register :another_token, :typed_with_name
    
    o3 = CodeObject::Base.new
    o3.process_token Parser::Tokenline.new(:another_token, "[Foo, Bar] My_name some content")
    
    o3.token(:another_token).first.content.should == "some content"
    o3.token(:another_token).first.name.should == "My_name"
    o3.token(:another_token).first.types.should == ['Foo','Bar']
  end 
  
  it "should raise an error if there is no Tokenhandler" do
    o4 = CodeObject::Base.new
    should_raise Token::NoTokenHandler do
    
    # TODO Schnittstelle Tokenline mit tokenname und content dokumentieren
      o4.process_token Parser::Tokenline.new(:some_fancy_token_name, "and the content for this unknown token")
    end
  end
  
  it "should process multiple tokens to array" do
    Token::Handler.register :some_token
    
    o1 = CodeObject::Base.new
    o1.process_token Parser::Tokenline.new :some_token, "some content one"    
    o1.process_token Parser::Tokenline.new :some_token, "some content two"    
    
    o1.token(:some_token).first.content.should == "some content one"
    o1.token(:some_token).last.content.should == "some content two"
    o1.token(:some_token).length.should == 2
  end 

end
