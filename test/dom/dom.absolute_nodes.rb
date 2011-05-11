require_relative '../../lib/dom/dom'
require_relative '../../lib/code_object/function'
require_relative '../../lib/processor'

describe Dom, ".add_child" do
  
  context "Parsing absolute.js" do
    
    before do 
      Dom.clear             
      Processor.process_file File.expand_path('../../js-files/absolute.js', __FILE__)
    end
    
    it "should find only one root-object" do
      Dom.children.length.should == 1
    end
    
    describe "Object 'Person'" do
    
      subject { Dom[:Person] }
    
      it "should have one child 'config'" do
        subject[:config].nil?.should == false
      end
    
    end
    
    describe "Object 'config'" do
    
      subject { Dom[:Person][:config] }
    
      it "should have 'Person' as parent" do
        subject.parent.should == Dom[:Person]
      end
    
    end
  
  end 

end
