require_relative '../../lib/parser/parser'

describe StringScanner, "#intelligent_skip_until" do
  
  context "closing braces in strings" do  
    before do
      @scanner = StringScanner.new "Foo bar baz \"this is a) string\" this is not) - and some more"
      @scanner.intelligent_skip_until /\)/
    end
    
    it "should find ) at pos 44" do
      @scanner.pos.should == 44
      @scanner.matched.should == ")"
    end  
  end
  
  
  context "closing braces in single-strings" do  
    before do
      @scanner = StringScanner.new "Foo bar baz 'this is a) string' this is not) - and some more"
      @scanner.intelligent_skip_until /\)/
    end
    
    it "should find ) at pos 44" do
      @scanner.pos.should == 44
      @scanner.matched.should == ")"
    end  
  end
  
  
  context "escaped string-ends" do  
    before do
      @scanner = StringScanner.new "Foo bar baz \"this is a) string\\\" this is not)\" - and )some more"
      @scanner.intelligent_skip_until /\)/
    end
    
    it "should find ) at pos 54" do
      @scanner.pos.should == 54
      @scanner.matched.should == ")"
    end  
  end
  
  context "strings as code context (pattern from scope search)" do
    before do
      @scanner = StringScanner.new "var string = \"1234567\;\"\nsome more"
      @scanner.intelligent_skip_until /\{|\(|\}|\)|$/
    end
    
    it "should find linebreak at pos 23" do
      @scanner.pos.should == 23
    end  
  end  
  
  context "regular expressions" do  
    before do
      @scanner = StringScanner.new "Foo bar baz /(a-z)_[\\(\\)]/ix - and )some more"
      @scanner.intelligent_skip_until /\)/
    end
    
    it "should find ) at pos 36" do
      @scanner.pos.should == 36
      @scanner.matched.should == ")"
    end  
  end
  
  
  context "escaped regular expressions" do  
    before do
      @scanner = StringScanner.new "Foo bar baz /(a-z)_[\\(\\)]\\/foo/ix - and )some more"
      @scanner.intelligent_skip_until /\)/
    end
    
    it "should find ) at pos 41" do
      @scanner.pos.should == 41
      @scanner.matched.should == ")"
    end  
  end
  
  
  context "single line comments" do  
    before do
      @scanner = StringScanner.new "Foo bar baz //(Oh a comment))\n - and )some more"
      @scanner.intelligent_skip_until /\)/
    end
    
    it "should find ) at pos 38" do
      @scanner.pos.should == 38
      @scanner.matched.should == ")"
    end     
  end
  
  
  context "multi line comments" do  
    before do
      @scanner = StringScanner.new "Foo bar baz 
/**
 * (Oh a comment))
 */ - and )some more"
      @scanner.intelligent_skip_until /\)/
    end
    
    it "should find ) at pos 47" do
      @scanner.pos.should == 47
      @scanner.matched.should == ")"
    end  
  end
  
  context "not ending single line comments" do  
    before do
      @scanner = StringScanner.new "Foo bar baz //(Oh a comment)) - and )some more"
    end
    
    it "should raise an exception" do
      should_raise StringScanner::Error do
        @scanner.intelligent_skip_until /\)/
      end
    end     
  end
  
end
