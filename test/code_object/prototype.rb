# ../data.img#1774507:1
require_relative '../../lib/code_object/object'

describe CodeObject::Prototype, ".new" do

  context "Parsing prototype.js" do
    
    before do
      Dom.clear
      Processor.process_file File.expand_path('../../js-files/prototype.js', __FILE__)
    end
    
    describe "the constructor-function" do    
      
      subject { Dom[:Person] }
      
      it "should be a CodeObject::Function" do
        subject.is_a?(CodeObject::Function).should == true
      end
      
      it "should have a children, called 'prototype'" do
        subject[:prototype].should == subject.prototype
        subject[:prototype].nil?.should == false
      end
      
      it "should be flagged as constructor" do
        subject.constructor?.should == true
      end
      
      it "should contain only one child" do
        subject.children.length.should == 1
      end
      
    end


    describe "the prototype-object" do    
      
      subject { Dom[:Person][:prototype] }
      
      it "should be a CodeObject::Prototype" do
        subject.is_a?(CodeObject::Prototype).should == true
      end
      
      it "should have Person as parent" do
        subject.parent.should == Dom[:Person]
        subject.constructor.should == subject.parent
        subject.constructor.nil?.should == false
      end
            
      it "should contain only one child" do
        subject.children.length.should == 1
      end
    end
    
    
    describe "the child of the prototype" do
      
      subject { Dom[:Person][:prototype][:sayHello] }
      
      it "should be a function" do
        subject.is_a?(CodeObject::Function).should == true
      end    
    end
    
  end 
  
end
