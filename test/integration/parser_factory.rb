require_relative '../../lib/parser/parser'
require_relative '../../lib/dom/dom'

describe CodeObject::Converter, ".build" do

  before do
    stream = File.read File.expand_path('../../js-files/tokens.js', __FILE__)
    @parser = Parser::Parser.new stream
    @comments = @parser.parse
    
    @objects = @comments.map {|comment| comment.to_code_object }.compact
  end
  
  it "should have built three objects" do
    @objects.length.should == 3
  end
  
  it "should have built the first object as Function" do
    @objects.first.class.should == CodeObject::Function
    @objects.first.name.should == "say_hello"
    @objects.first.token(:public).nil?.should == false
  end

  it "should have built the second object as Object" do
    @objects[1].class.should == CodeObject::Object
    @objects[1].name.should == "FOO"
  end  
end
