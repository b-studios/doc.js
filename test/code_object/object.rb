# ../data.img#1774507:1
require_relative '../../lib/code_object/object'

describe CodeObject::Object, ".new" do

=begin @todo rewrite
  before do
    @o1 = CodeObject::Object.new :foo
    @o2 = CodeObject::Object.new :bar, @o1
    @o3 = CodeObject::Object.new :baz, @o2
  end

  it "should save children as properties" do  
    @o1.properties.should == {:bar => @o2}
    @o2.properties.should == {:baz => @o3}
    @o3.properties.should == {}
  end  
  
  it "should not allow duplicate properties" do  
    should_raise CodeObject::PropertyAlreadyDefined do
      CodeObject::Object.new :bar, @o1
    end
  end  
=end
  
end
