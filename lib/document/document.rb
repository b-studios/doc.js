require_relative '../dom/dom'

module Document

  class Document
  
    include Dom::Node
    
    FILE_ENDINGS = /\.(markdown|mdown|md|mkd|mkdn)$/i
    
    attr_reader :name, :content
  
    def initialize(path, content)
      
      name = File.basename(path).gsub(FILE_ENDINGS, '')
      
      # please do not confuse Filepath of Document (like docs/README.md) with path in Dom
      # an .md will be stripped from the name and README.SOMEMORE.md can be used as path information
      @name, @content = name, content
      super()
    end
    
  end
  
end