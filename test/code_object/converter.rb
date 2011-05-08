# ../data.img#1785915:1
require_relative '../../lib/parser/comment'

describe CodeObject::Converter, ".to_code_object" do

  before do
    @comment1 = Parser::Comment.new
    @comment1.add_docline "Some documentation"
    @comment1.add_tokenline :function, "foo"
    
    @comment2 = Parser::Comment.new
    @comment2.add_tokenline "object", "bar"
    
    @comment3 = Parser::Comment.new
    @comment3.add_tokenline "another_unknown_token"
    
    @comment4 = Parser::Comment.new "No tokens"    
    
    @comment5 = Parser::Comment.new
    @comment5.add_tokenline :function, "foo"
    @comment5.add_tokenline :object, "bar"
  end
  
  it "should create a function from comment1" do
    code_object = @comment1.to_code_object
    code_object.class.should == CodeObject::Function
  end
  
  it "should create an object from comment2" do
    code_object = @comment2.to_code_object   
    code_object.class.should == CodeObject::Object
  end

  it "should create nothing from comment3" do
    code_object = @comment3.to_code_object
    code_object.should == nil
  end
  
  it "should create nothing from comment4" do
    code_object = @comment4.to_code_object
    code_object.should == nil
  end
  
  it "should raise error with multiple type declarations" do
    should_raise CodeObject::MultipleTypeDeclarations do 
      @comment5.to_code_object
    end
  end

end
