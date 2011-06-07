require_relative '../../lib/parser/comment'
require_relative '../../lib/code_object/function'

require_relative '../../templates/tokens/tokens'

describe Token::Handler, ".register" do
  
  before :each do
    @object = CodeObject::Function.new
  end
  
  context "token @example with name" do
  
    before do 
      @object.process_token(Parser::Tokenline.new(:example, "MyName \nThis is a multiline \nCodeexample."))
    end
    
    describe "the token" do
      
      subject { @object.tokens[:example].first }
    
      it "should have a correct name" do
        subject.name.should == "MyName"
      end    
      
      it "should have correct content" do
        subject.content.should == "This is a multiline \nCodeexample."
      end
    end    
  end
  
  
  context "token @example without name" do
  
    before do 
      @object.process_token(Parser::Tokenline.new(:example, "\nThis is a multiline \nCodeexample."))
    end
    
    describe "the token" do
      
      subject { @object.tokens[:example].first }
    
      it "should have empty name" do
        subject.name.should == ""
      end    
      
      it "should have correct content" do
        subject.content.should == "This is a multiline \nCodeexample."
      end
    end    
  end
end

