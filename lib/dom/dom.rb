require_relative 'no_doc'
require_relative 'exceptions'

# Storing {CodeObject::Base Objects}
# ==================================
#
# The datastructure is based on a treelike concept. Every new inserted 
# {CodeObject::Base object} is represented by a {Dom::Node node} of the tree. 
# There are three types of nodes:
#
#   1. {Dom::NoDoc Not documented nodes} that contain other nodes
#   2. {Dom::Node Documented nodes}, that contain other nodes
#   3. Leafs of the tree, without children. (Those leafs have to be 
#       {Dom::Node documented nodes})
#  
# The architecure of the Dom looks pretty much like this:
#
# ![Dom Architecture](../uml/Dom.svg)
#
# Take the following code-sample:
#
#     /**
#      *  @function Foo.bar
#      */
#
# The tree could look like:
#  
#     ROOT
#      |
#     Foo (not documented)
#      |
#     bar
#    
# Extending this example with two other comments
#
#     /**
#      *  @object Foo
#      */
#     
#     /**
#      *  @object Foo.baz
#      */
#     
# leads to this tree:
#
#       ROOT
#        |
#       Foo
#       / \
#     bar baz
#      
# Now all nodes are documented (i.e. a CodeObject exists for every node) and `Foo`
# contains two other CodeObjects. `bar` and `baz` are leafs of the tree.
# 
# Adding a new node to the tree is as simple as:
# 
#     Dom.add_node "Foo.bar", my_code_object
#
# Traversing the Tree
# -------------------
# There are several method, which you can use to navigate throught the dom. The
# most important is the {Dom::Node#[] children selector}.
# 
# The tree above could be traversed using the following operations:
# 
#     Dom[:Foo]
#     #=> #<CodeObject::Base:72903230 @parent=__ROOT__ @children=[:bar, :baz]> 
#
#     Dom[:Foo][:bar]
#     #=> #<CodeObject::Base:72919910 @parent=Foo @children=[]>
#
#
# The Root Node
# -------------
# The Dom inherits functionality from it's **root-node**. So all method's
# invoked on the root node, can be expressed equivalent as member of the Dom.
#     
#     Dom.root[:some_child] <=> Dom[:some_child]
#     Dom.root.children <=> Dom.children
#     Dom.root.print_tree <=> Dom.print_tree
#
# Please note, that some methods of the root-node are hidden behind direct
# implementations.
# 
#     Dom.add_node != Dom.root.add_node 
#
# For the example above the full UML-Graph, including the root-node, could look
# like:
#
# ![dom tree sample](../uml/dom_tree_sample.svg)
# 
# @example Adding some Nodes
#   o1 = CodeObject::Object.new "foo"
#   o2 = CodeObject::Object.new "poo"
#   o3 = CodeObject::Object.new "bar"
#   o4 = CodeObject::Object.new "baz"
#   Dom.add_node "foo", o1
#   Dom.add_node "foo.poo", o2
#   Dom.add_node "foo.poo.bar", o3
#   Dom.add_node "foo.poo.baz", o4
#
#   Dom.print_tree
#   # -foo
#   #   -poo
#   #     -bar
#   #     -baz
#
# Using the Dom for Documents
# -------------------------------
# The Dom can be used in **two** ways. Because Document-structure can be very similiar to the one
# of our documentation-elements there are two kind of `root-nodes`:
#
# 1. {Dom.root}
# 2. {Dom.docs}
#
# @see Dom::Node
# @see Dom::NoDoc
# @see CodeObject::Base
# @see Document::Document
module Dom

  @@cache_path = File.expand_path("../../../cache/dom.cache", __FILE__)
  
  @@root = NoDoc.new('__ROOT__')
  @@docs = NoDoc.new('__DOCUMENTS__')
  
  
  # @group Dom Access-Methods
  
  # @return [Dom::NoDoc] The Dom's root-node
  def self.root
    @@root
  end
  
  # @group Dom Management Methods
  
  # Reset the Dom to it's initial state by creating an empty {.root root-node}
  def self.clear
    @@root = NoDoc.new('__ROOT__')
  end
  
  # @group Caching Methods
  
  # Serializes and dumps the complete Domtree (but without last_position) to the 
  # specified `path`. If no `path` is given, the default `@@cache_path` will be 
  # used instead.
  #
  # This Method can be useful, to save a specific state of the Domtree to disk
  # and reuse it later, without the need to reconstruct it from zero.
  #
  # @note To recreate the Dom from the dump-file, use {.load}.
  #
  # @param [String] file the filepath, where to write the serialized data
  def self.dump(file = @@cache_path)
    File.open(file, 'w') do |f|
      f.write Marshal.dump @@root
    end
  end
  
  # Loads the {.dump serialized Dom} and replaces the current root node with
  # the one created from the file.
  #
  # @see .dump
  # @param [String] file the filepath from which to load the Dom
  def self.load(file = @@cache_path)
    @@root = Marshal.load(File.read(file))
  end
  
  # @group Document Objects
  
  # @return [Dom::NoDoc] the root of the Documenttree, consisting of {Document::Document}
  def self.docs
    @@docs
  end
  
  protected
  
  # try to look up missing methods in @@root
  def self.method_missing(method_name, *args)
    if @@root.respond_to? method_name
      @@root.send method_name, *args
    else
      raise NoMethodError.new(method_name.to_s)
    end
  end
  
end