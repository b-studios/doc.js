require_relative '../../lib/parser/parser'
require_relative '../../lib/dom/dom'

describe CodeObject::Converter, "#to_code_object" do

  context "Parsing tokens.js" do
  
    before do
      Dom.clear
          
      stream = File.read File.expand_path('../../js-files/tokens.js', __FILE__)
      comments = Parser::Parser.new(stream).parse      
      @objects = comments.map {|comment| comment.to_code_object }.compact
    end
  
    it "should have built three objects" do
      @objects.length.should == 3
    end
  
    describe "First CodeObject" do
      subject { @objects[0] }
      
      it "should be a function named 'say_hello'" do
        subject.class.should == CodeObject::Function
        subject.name.should == "say_hello"
      end
      
      it "should have a 'public'-token" do
        subject.token(:public).nil?.should == false
        subject.token(:public).length.should == 1
      end
      
      it "should have one param 'foo'" do
        subject.params.length.should == 1
        subject.params.first.should_be_named_typed_token("foo", ["String"], "some parameter\n")
      end
      
      it "should have a return value" do
        subject.returns.length.should == 1
        subject.returns.first.should_be_typed_token(['String', 'Integer'], "returns a string \"hello\"\n")
      end
    end
    
    describe "Second CodeObject" do
      subject { @objects[1] }
    
      it "should be an Object named 'FOO'" do
        subject.class.should == CodeObject::Object
        subject.name.should == "FOO"
      end    
    end
    
    describe "Third CodeObject" do
      subject { @objects[2] }
    
      it "should be an Function named 'some_function'" do
        subject.class.should == CodeObject::Function
        subject.name.should == "some_function"
      end
      
      it "should be flagged as constructor" do
        subject.constructor?.should == true
      end
      
      it "should contain one param 'parameter1'" do
        subject.params.length.should == 1
        subject.params.first.should_be_named_typed_token("parameter1", ["String"], "The first parameter\n")        
      end
    end
  
  end 
end
