require_relative 'parser/parser'
require_relative 'dom/dom'

module Processor

  def self.process_file(file)
    comments = Parser::Parser.parse_file file      
    comments.each { |comment| process_comment(comment) }
  end
  
  def self.process_comment(comment)
    code_object = comment.to_code_object            # convert to code_object
    Dom.add_node(code_object.path, code_object)     # add to dom
  end
  
end
