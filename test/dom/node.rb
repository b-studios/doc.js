# ../data.img#1772233:1
require_relative '../../lib/dom/dom'
require_relative '../../lib/code_object/base'

describe Dom::Node, "#resolve" do

  before do
    Dom.clear
    @o1 = CodeObject::Base.new 
    @o2 = CodeObject::Base.new
    @o3 = CodeObject::Base.new
    @o4 = CodeObject::Base.new
    
    Dom.add_node "Foo.bar" , @o1
    @o1.add_node ".baz"    , @o2  
    @o1.add_node ".baz.bam", @o3
    @o1.add_node ".baz.poo", @o4
  end

  it "should find existing node in domtree" do
    @o4.resolve('.bar').should == @o1
    @o4.resolve('.baz').should == @o2
    @o4.resolve('.bam').should == @o3
    @o4.resolve('.poo').should == @o4    
  end
  
  it "should not find non existing nodes" do
    @o1.resolve('fofofo').should == nil
  end
end

describe Dom::Node, "#qualified_name" do

  before do
    Dom.clear
    @o1 = CodeObject::Base.new "bar"
    @o2 = CodeObject::Base.new "baz"
    @o3 = CodeObject::Base.new "bam"
    @o4 = CodeObject::Base.new "poo"
    
    Dom.add_node "Foo.bar" , @o1
    @o1.add_node ".baz"    , @o2  
    @o1.add_node ".baz.bam", @o3
    @o1.add_node ".baz.poo", @o4
  end
  
  it "should generate correct qualified name from structure" do      
    @o1.qualified_name.should == "Foo.bar"
    @o2.qualified_name.should == "Foo.bar.baz"
    @o3.qualified_name.should == "Foo.bar.baz.bam"
    @o4.qualified_name.should == "Foo.bar.baz.poo"
  end
end
