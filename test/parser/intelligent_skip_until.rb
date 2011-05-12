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
=begin  
  
  context "Parsing a File with nested comments and strings" do

    before do  
      @path = File.expand_path('../../js-files/nested_with_strings.js', __FILE__)
      stream = File.read @path
      @parser = Parser::Parser.new(stream, :filepath => @path)
      @comments = @parser.parse
    end
    
    subject { @comments }
    
    it "should find 1 root comments" do
      subject.length.should == 1
    end
    
    
    describe "the first comment" do
    
      subject { @comments.first }
      
      it "should containt 0 doclines and 1 tokenline" do
        subject.doclines.length.should == 0
        subject.tokenlines.length.should == 1
      end
      
      it "should have got correct tokenline-contents" do
        tokens = subject.tokenlines        
        tokens[0].token.should == :function        
        tokens[0].content.should == "Outer\n"
      end
      
      it "should start at line 4" do
        subject.line_start.should == 4
      end
      
      it "should contain the right filepath" do
        subject.filepath.should == @path
      end
      
      it "should contain the right source" do
        subject.source.should == "var Outer = function(){
  
  /**
   * This is an inner function
   * @function .inner
   */
   var inner = function() {
   
   }
   
   
  /**
   * This is a second inner function
   * @function .inner_two
   */
   var innerTwo = function() {
   
   
      /**
       * And again, here is a inner function
       * @object .foo
       */
        var foo = {
          bar: 4,
          baz: function() {}          
        };   
   
   
   }
  
};"
      end      
      
      it "should contain 2 child-comments" do 
        subject.children.length.should == 2
      end      
    end
    
    
    describe "the first inner comment" do
    
      subject { @comments.first.children.first }
      
      it "should contain 1 doclines and 1 tokenline" do
        subject.doclines.length.should == 1
        subject.tokenlines.length.should == 1
      end
      
      it "should have got correct tokenline-contents" do
        tokens = subject.tokenlines        
        tokens[0].token.should == :function        
        tokens[0].content.should == ".inner\n"
      end
      
      it "should start at line 10" do
        subject.line_start.should == 10
      end
      
      it "should contain the right filepath" do
        subject.filepath.should == @path
      end
            
    end
        
        
    describe "the second inner comment" do
    
      subject { @comments.first.children[1] }
      
      it "should contain 1 doclines and 1 tokenline" do
        subject.doclines.length.should == 1
        subject.tokenlines.length.should == 1
      end
      
      it "should have got correct tokenline-contents" do
        tokens = subject.tokenlines        
        tokens[0].token.should == :function        
        tokens[0].content.should == ".inner_two\n"
      end
      
      it "should start at line 19" do
        subject.line_start.should == 19
      end
      
      it "should contain the right filepath" do
        subject.filepath.should == @path
      end  
      
    end
    
    
    describe "the most inner comment" do
    
      subject { @comments.first.children[1].children.first }
      
      it "should contain 1 doclines and 1 tokenline" do
        subject.doclines.length.should == 1
        subject.tokenlines.length.should == 1
      end
      
      it "should have got correct tokenline-contents" do
        tokens = subject.tokenlines        
        tokens[0].token.should == :object        
        tokens[0].content.should == ".foo\n"
      end
      
      it "should start at line 26" do
        subject.line_start.should == 26
      end
      
      it "should contain the right filepath" do
        subject.filepath.should == @path
      end      
      
    end
    
  end
=end    
end
