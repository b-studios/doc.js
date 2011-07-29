require_relative '../dom/dom'

module Document

  # Document is used to represent Markdown-Files (which should provied further help to your 
  # generated docs)
  # Each given Markdown-File is converted in a {Document::Document} and then added to {Dom.docs}
  # Like the {file:USE.md#Namespacing namespacing} in JavaScript-Comments there is a 
  # naming-convention for Markdown-files if you wish to store them in a tree-like structure.
  #
  #     docs/README.md
  #     docs/README.CONCEPT.md
  #     docs/README.ARCHITECTURE.md
  #
  # will result in a tree:
  #
  #           Dom.docs
  #              |
  #            README
  #          /        \
  #     CONCEPT ARCHITECTURE
  #
  # @todo it would be much nicer, if a directory is provided in the CLI (like :docs => "/my/docs")
  #   that this tree-structure is reconstructed from the directory-structure. Naming files like
  #   `My.Awesome.File.md` is not that elegant.
  class Document
  
    include Dom::Node
    
    FILE_ENDINGS = /\.(markdown|mdown|md|mkd|mkdn)$/i
    
    attr_reader :name, :path, :content
  
    def initialize(path, content)
      
      path = File.basename(path).gsub(FILE_ENDINGS, '')
      
      # please do not confuse Filepath of Document (like docs/README.md) with path in Dom
      # an .md will be stripped from the name and README.SOMEMORE.md can be used as path information
      @path, @name, @content = ".#{path}", extract_name_from(path), content
      super()
    end
    
  end
  
end