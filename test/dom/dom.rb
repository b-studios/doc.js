# ../data.img#1811393:1
require_relative '../../lib/dom/dom'
require_relative '../../lib/code_object/function'

describe Dom, ".add_child" do

  before do
    Dom.clear
    @o1 = CodeObject::Object.new
    @o2 = CodeObject::Object.new
  end
  
  it "should add absolute nodes" do
    Dom.add_node "Foo", @o1
    Dom[:Foo].should == @o1
  end
  
  it "should add absolute nodes from node" do
    @o1.add_node "Foo", @o2
    Dom[:Foo].should == @o2
  end
  
  it "should insert missing nodes as NoDoc" do
    Dom.add_node "Foo.bar.baz.bam", @o1
    Dom[:Foo].class.should == Dom::NoDoc
    Dom[:Foo][:bar].class.should == Dom::NoDoc
    Dom[:Foo][:bar][:baz].class.should == Dom::NoDoc
    Dom[:Foo][:bar][:baz][:bam].should == @o1
  end
  
  it "should replace NoDoc-leafs with nodes" do
    Dom.add_node "Foo.bar.baz.bam", @o1
    Dom.add_node "Foo.bar.baz", @o2
    Dom[:Foo].class.should == Dom::NoDoc
    Dom[:Foo][:bar].class.should == Dom::NoDoc
    Dom[:Foo][:bar][:baz].should == @o2
    Dom[:Foo][:bar][:baz][:bam].should == @o1
  end
  
  it "should not allow replacing existing node" do
    Dom.add_node "Foo.bar.baz.bam", @o1
    
    should_raise Dom::NodeAlreadyExists do
      Dom.add_node "Foo.bar.baz.bam", @o2
    end
  end
  
  it "should reject not wellformed paths" do    
    [ "Foo..bar.baz.bam",
      "-foo.bar-baz.foo",
      ""
    ].each do |path|
      should_raise Dom::WrongPath do
        Dom.add_node path, @o2
      end
    end
  end
  
  it "should set correct parent, while rebuilding" do
    Dom.add_node "Foo.bar.baz.bam", @o1
    Dom.add_node "Foo.bar.baz", @o2
    
    @o1.parent.should == @o2
  end  
  
  it "should append relative paths to current object" do
    Dom.add_node "Foo.bar", @o1    
    @o1.add_node ".poo", @o2
    
    Dom[:Foo][:bar][:poo].should == @o2    
  end
end
