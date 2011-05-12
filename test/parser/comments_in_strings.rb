#encoding utf-8

require_relative '../../lib/parser/parser'

describe Parser::Parser, ".parse" do

  context "Parsing comments_in_strings.js" do

    before do  
      stream = File.read File.expand_path('../../js-files/comments_in_strings.js', __FILE__)
      @parser = Parser::Parser.new stream
      @comments = @parser.parse
    end
    
    subject { @comments }
    
    it "should find 1 comment" do
      subject.length.should == 1
    end
    
    
    describe "The First Comment" do
    
      subject { @comments.first }
      
      it "should contain 1 docline and 1 tokenline" do
        subject.doclines.length.should == 1
        subject.tokenlines.length.should == 1
      end
      
      it "should have got correct tokenline-contents" do
        tokens = subject.tokenlines        
        tokens[0].token.should == :object        
        tokens[0].content.should == "only_one\n"
      end      
      
      it "should have got correct source" do
        subject.source.should == "  var innerTwo = function() {
      
      var another_string = \"({})\\n\\n\\n)){()[])\"
   
      single_string = '// @object .foo'
        var foo = {
          bar: 4,
          baz: function() {}          
        };      
   } "
      end
    end
  end
end
