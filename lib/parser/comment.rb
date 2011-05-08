# ../data.img#1781829:1
require_relative 'meta_container'
require_relative '../code_object/converter'

module Parser

  # Together with {Parser::Coment} it acts as an **Interface** between {Parser} 
  # and {CodeObject}. Parser::Comment creates instances of Tokenline, which are
  # then analysed by {Token::Container#process_token} 
  #
  # @see Parser::Comment
  # @see Parser::CommentParser
  Tokenline = Struct.new :token, :content
  
  # Comment contains all **tokenlines** and **doclines**, which are created by the
  # {Parser::Parser parser}. The tokenlines are stored as {Tokenline}. Because
  # of this Comment and Tokenline act as **Interface** for {CodeObject::Base}.
  #
  # The tokens will further be processed by {Token::Container}, which 
  # is mixed in to CodeObject::Base).
  #
  # @example creating of an comment
  #   c = Parser::Comment.new "the original string of the comment, with all tokens and doclines"
  #   c.add_tokenline :param "[String] first_parameter this is the description for param1"
  #   c.add_docline "Some documentation of the comment"
  #
  # @example access of comment-data
  #   c.tokenlines.first.token #=> :param
  #   c.tokenlines.first.content #=> "[String] first_parameter this is the description for param1"
  #   c.doclines #=> ["Some documentation of the comment"]
  class Comment   
    
    include MetaContainer
    include CodeObject::Converter
    
    attr_reader :tokenlines, :doclines, :children
    
    def initialize(comment_text = "")
      @original_comment = comment_text
      
      @tokenlines, @doclines, @children = [], [], []
    end
    
    # @param [String, Symbol] tokenname
    # @param [String] content
    def add_tokenline(tokenname, content = "")
      @tokenlines << Tokenline.new(tokenname.to_sym, content)
    end
    
    # @param [String] docline
    def add_docline(docline)
      @doclines << docline
    end
    
    # @param [Array<Comment>] comments
    def add_children(comments)
      @children += comments
    end
    
    def has_tokens?
      not @tokenlines.empty?
    end    
    
    def to_s
      "#<Parser::Comment tokenlines=#{@tokenlines.length} doclines=#{@doclines.length}>"
    end
    
  end
end
