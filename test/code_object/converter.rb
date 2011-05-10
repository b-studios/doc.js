# ../data.img#1785915:1
require_relative '../../lib/parser/comment'

describe CodeObject::Converter, "#to_code_object" do

  before :each do
    @comment = Parser::Comment.new
  end

  context "comment with function-token" do
  
    before do      
      @comment.add_tokenline :function, "foo"
    end
    
    describe "the result" do
      
      subject { @comment.to_code_object }
      
      it "should be a CodeObject::Function" do
        subject.class.should == CodeObject::Function
      end
      
    end 
  end

  context "comment with object-token" do
  
    before do      
      @comment.add_tokenline "object", "bar"
    end
    
    describe "the result" do
      
      subject { @comment.to_code_object }
      
      it "should be a CodeObject::Object" do
        subject.class.should == CodeObject::Object
        subject.name.should == "bar"
      end
      
    end 
  end
  
  context "comment with unknown token" do
  
    before do      
      @comment.add_tokenline "some_unkown_token", "bar"
    end    
    
    it "should not create a CodeObject" do
      @comment.to_code_object.should == nil
    end
  end
  
  context "comment with no tokens" do
      
    it "should not create a CodeObject" do
      @comment.to_code_object.should == nil
    end
    
  end
  
  context "comment with multiple tokens" do
      
    before do
      @comment.add_tokenline "function", "foobar"
      @comment.add_tokenline "object", "baz"
    end
      
    it "should raise an error" do
      should_raise CodeObject::MultipleTypeDeclarations do 
        @comment.to_code_object
      end
    end
    
  end
end
