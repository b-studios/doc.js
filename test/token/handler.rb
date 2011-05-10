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

  
  context "processing a token without handler" do
    
    token = Parser::Tokenline.new :test_handler, "[Foo, Bar, Baz] MyName This is some content"
    
    it "should raise an error" do
      should_raise Token::NoTokenHandler do
        @object.process_token(token)
      end
    end 
       
  end
  
  
  context "multiple tokens of the same type" do
  
    before do
      Token::Handler.register :test_handler
      @object.process_token Parser::Tokenline.new :test_handler, "This is some content"
      @object.process_token Parser::Tokenline.new :test_handler, "And another one"
      @object.process_token Parser::Tokenline.new :test_handler, "Third content"
    end
    
    subject { @object.token(:test_handler) }
    
    it "should be processed to an array" do
      subject.length.should == 3
      subject[0].content.should == "This is some content"
      subject[1].content.should == "And another one"
      subject[2].content.should == "Third content"
    end
      
  end
  
  
  context "using a user-defined block as token-handler" do
    
    before do
      Token::Handler.register(:test_handler) do |token, content|
        define_singleton_method :test_token do 
          token
        end
        
        define_singleton_method :test_content do 
          content
        end
      end
      @object.process_token Parser::Tokenline.new :test_handler, "This is some content"
    end
    
    it "should be added to the list of handlers" do
      Token::Handler.handlers.include?(:test_handler).should == true
    end
    
    it "should be evaled in CodeObject context" do
      @object.test_token.should == :test_handler
      @object.test_content.should == "This is some content"
    end
    
  end
end
