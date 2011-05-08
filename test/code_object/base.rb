# ../data.img#1797279:1
require_relative '../../lib/code_object/base'

describe CodeObject::Base, ".new" do

=begin @todo rewrite
  before do
    @o1 = CodeObject::Base.new :foo
    @o2 = CodeObject::Base.new :bar, @o1
    @o3 = CodeObject::Base.new :baz, @o2
  end

  it "should nest properly" do  
    @o1.parent.should == nil
    @o2.parent.should == @o1
    @o3.parent.should == @o2
  end
  
  it "should create right namespace" do
    @o1.namespace.should == ''
    @o2.namespace.should == 'foo'
    @o3.namespace.should == 'foo::bar'
  end
  
  it "should find all parents" do
    @o1.parents.should == []
    @o2.parents.should == [@o1]
    @o3.parents.should == [@o1, @o2]
  end
  
  it "should have a full qualified name" do
    @o1.qualified_name.should == "foo"
    @o2.qualified_name.should == "foo::bar"
    @o3.qualified_name.should == "foo::bar::baz"
  end
=end 
end
