# ../data.img#1771563:1
require_relative '../../lib/parser/comment'
require_relative '../../lib/code_object/function'

describe Token::Handler, ".register" do
  
  before :each do
    Token::Handler.unregister :test_handler
    @object = CodeObject::Function.new
  end
  
  after :all do
    Token::Handler.unregister :test_handler
  end
  
  context "using a default handler" do    
  
    before do 
      Token::Handler.register :test_handler
      token = Parser::Tokenline.new :test_handler, "This is some content"
      @object.process_token(token)
    end
    
    describe "the processed token" do
      subject { @object.token(:test_handler).first }
      
      it "should have got the correct content" do
        subject.content.should == "This is some content"
      end
    end    
    
  end

  context "using a typed handler" do    
  
    before do 
      Token::Handler.register :test_handler, :typed
      token = Parser::Tokenline.new :test_handler, "[MyType] This is some content"
      @object.process_token(token)
    end
    
    describe "the processed token" do
      subject { @object.token(:test_handler).first }
      
      it "should have got correct type and content" do 
        subject.types.should == ["MyType"]
        subject.content.should == "This is some content"
      end
    end    
    
  end

  context "using a typed_with_name handler" do    
  
    before do 
      Token::Handler.register :test_handler, :typed_with_name
      token = Parser::Tokenline.new :test_handler, "[Foo, Bar, Baz] MyName This is some content"
      @object.process_token(token)
    end
    
    describe "the processed token" do
      subject { @object.token(:test_handler).first }
      
      it "should have got correct typedname and content" do 
        subject.types.should == ["Foo", "Bar", "Baz"]
        subject.name.should == "MyName"
        subject.content.should == "This is some content"
      end
    end    
    
  end

  it "should add a block to the list of tokenhandlers" do  
    some_block = lambda {|token, content| puts "test" }    
    Token::Handler.register :foobar, some_block    
    Token::Handler.handlers.include?(:foobar).should == true
  end 
  
end
