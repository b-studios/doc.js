require_relative 'node'

module Dom
  
  # NoDoc is used by {Dom} and {Dom::Node} to preserve the correct hierachy of
  # the tree, while inserting nodes with non (or not yet) existing parents.
  #
  # For example let's add the node 'foo.bar.baz' in our empty Dom. This will 
  # result in the following tree:
  #
  #     -foo (NoDoc)
  #       -bar (NoDoc)
  #         -baz
  #
  # If a documented node with the same path is inserted, the NoDoc-node will be replaced by it.
  class NoDoc
    include Node
    
    attr_reader :name
    
    def initialize(name)
      @name = name
      super()
    end
  end
end
