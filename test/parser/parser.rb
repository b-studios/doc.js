#encoding utf-8

require_relative '../../lib/parser/parser'

describe Parser::Parser, ".parse" do

  context "Parsing simple.js" do

    before do  
      stream = File.read File.expand_path('../../js-files/simple.js', __FILE__)
      @parser = Parser::Parser.new stream
      @comments = @parser.parse
    end
    
    subject { @comments }
    
    it "should find 1 comment" do
      subject.length.should == 1
    end
    
    
    describe "The First Comment" do
    
      subject { @comments.first }
      
      it "should contain 3 doclines and 2 tokenlines" do
        subject.doclines.length.should == 5
        subject.tokenlines.length.should == 2
      end
      
      it "should have got correct tokenline-contents" do
        tokens = subject.tokenlines
        
        tokens[0].token.should == :first
        tokens[1].token.should == :second
        
        tokens[0].content.should == "tokenline\n"
        tokens[1].content.should == "tokenline, which should be a multiline token\n because it is intended with at least 2 spaces and\n it won't stop, until there is an empty line, or a\n new token\n"
      end
      
    end
  end



  context "Parsing a File with nested comments" do

    before do  
      @path = File.expand_path('../../js-files/nested.js', __FILE__)
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



  context "being confronted with windows-linebreaks \\r \\n" do

    before do  
      @parser = Parser::Parser.new("/**\r\n *\r\n * @tokenline with something fancy\r\n * @multiline token with\r\n *   continue over line end\r\n *  */")
      @comments = @parser.parse
    end  

    it "should parse tokenlines correct" do
      tokens = @comments.first.tokenlines
      
      tokens[0].token.should == :tokenline
      tokens[1].token.should == :multiline
      
      tokens[0].content.should == "with something fancy\n"
      tokens[1].content.should == "token with\n continue over line end\n"
    end
  end
  
  context "parsing multibyte character" do
=begin
    before do  

      @parser = Parser::Parser.new("/**
 *
 * @tokenline ÜÄÖÖüäöüöäßø
 * @multiline token with
 *   continue over line end
 *  
 */
Foo Bar")
      @comments = @parser.parse
    end  

    subject { @comments.first }
  
    it "should find the correct source" do
      subject.source.should == "Foo Bar"
    end
    
=end
    pending("There are Problems with utf-8 encoded string")
  end
  
  
end
