#<Encoding:UTF-8>

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
        tokens[1].content.should == "tokenline, which should be a multiline token\nbecause it is intended with at least 2 spaces and\nit won't stop, until there is an empty line, or a\nnew token\n"
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
      tokens[1].content.should == "token with\ncontinue over line end\n"
    end
    
  end
  
  context "multiline tokens with empty first line" do

    before do  
      @comments = Parser::Parser.new("
/**
 * @multiline
 *  this is a multiline token with
 *  empty first line
 */
").parse
    end  

    describe "the multiline token" do

      subject { @comments.first.tokenlines[0] }
      
      it "should be named :multiline" do
        subject.token.should == :multiline
        subject.content.should == "\nthis is a multiline token with\nempty first line\n"
      end
    end  
  end
  
  
  context "parsing regular expressions" do
  
    before do
      
      @comments = Parser::Parser.new("/**
 * @function _dispatchResponse    
 */       
function _dispatchResponse(response) {
  var code = response.statusCode;
  var data = response.data || response.rawData;

  _respond(code.toString().replace(/\d{2}$/, 'XX'), data, response);
}").parse
    end
    
    subject { @comments.first }
  
    it "should find the correct source" do
      subject.source.should == "function _dispatchResponse(response) {
  var code = response.statusCode;
  var data = response.data || response.rawData;

  _respond(code.toString().replace(/\d{2}$/, 'XX'), data, response);
}"
    end
  end
  
  context "parsing strings and lineends correctly for scope" do
    before do
      @comments = Parser::Parser.new("/**
 * @object someString
 */
var string =  \"1234567\";
").parse
    end
    
    subject { @comments.first }
    
    it "should parse the string correctly" do
      subject.source.should == "var string =  \"1234567\";\n"
    end
  end
  
  
  context "parsing multibyte character" do

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
   
  end  
  
end
