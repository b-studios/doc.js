# ../data.img#1780307:3
require_relative 'dom'
require_relative 'exceptions'

module Dom

  # Node can be seen as an **aspect** or feature of another Object. Therefore it can
  # be mixed in to add Dom::Node functionality to a class.
  # Such functionality is used by {CodeObject::Base}
  #
  # Instance Variables
  # ------------------
  # The following instance-variables will be set while including Dom::Node into
  # your class:
  #
  # - `@name` (should be already set in your including class)
  # - `@parent`
  # - `@children` 
  #
  # @example
  #   class MyObject
  #     include Dom::Node
  #     
  #     # The contructor of MyObject should call init_node
  #     def initialize(name)
  #       super
  #       @name = name
  #     end
  #   end
  #   
  #   # MyObject can now be used as a node within our Domtree
  #   @baz = MyObject.new 'Baz'
  #   @baz.add_node(MyObject.new 'foo')
  #   @baz.add_node(MyObject.new 'bar')
  #
  #   # These Nodes get inserted into Dom, so it looks like
  #   Dom.print_tree
  #   #=>
  #   #-Baz
  #   #  -foo
  #   #  -bar
  #  
  # @note including Class should implement instance-variable @name
  # @see CodeObject::Base
  # @see Dom
  module Node

    NS_SEP_STRING = '.'
    NS_SEP = /#{Regexp.escape(NS_SEP_STRING)}/
    
    NODENAME = /[0-9a-zA-Z$_]+/
    LEAF = /^#{NS_SEP}(?<name>#{NODENAME})$/
    ABSOLUTE = /^(?<first>#{NODENAME})(?<rest>(#{NS_SEP}#{NODENAME})*)$/
    RELATIVE = /^#{NS_SEP}(?<first>#{NODENAME})(?<rest>(#{NS_SEP}#{NODENAME})*)$/
    
    
    # @group Initialization
    
    # The 'constructor' of {Dom::Node}. It initializes all required 
    # instance-variables (see {Dom::Node above}).
    def initialize
      super
      @children, @parent = {}, nil
      @name ||= "" # should be written by including class
    end   
    
    # @group Traversing
    
    # `node.parent` returns the parent {Dom::Node node}, if there is one.
    # If no parent exists `nil` is returned. In this case `node` can be
    # considered either as loose leave or root of the {Dom}.
    #
    # @return [Dom::Node] the parent node, if one exists
    def parent
      @parent
    end
    
    
    # searches all parents recursivly and returns an array, starting with the
    # highest order parent (excluding the {Dom.root}) and ending with the  
    # immediate parent.
    #
    # @example
    #   o1 = CodeObject::Base.new :foo
    #   o2 = CodeObject::Base.new :bar, o1
    #   o3 = CodeObject::Base.new :baz, o2
    #
    #   # no parents
    #   o1.parents #=> []
    #
    #   # all parents
    #   o3.parents #=> [#<CodeObject::Base:foo>, #<CodeObject::Base:bar>]
    #
    # @return [Array<Dom::Node>] the associated parents
    def parents
      return [] if @parent.nil? or @parent.parent.nil?
      @parent.parents << @parent
    end
    
    
    # Returns all immediately associated children of this `node`
    #
    # @return [Hash<Symbol, Dom::Node>]
    def children
      @children
    end
    
    
    # Get's the child of this node, which is identified by `path`
    # 
    # @example childname
    #   Dom[:Core]             #=> #<CodeObject::Object:Core @parent=__ROOT__ …>
    #   Dom['Core']            #=> #<CodeObject::Object:Core @parent=__ROOT__ …>
    #
    # @example path
    #   Dom['Core.logger.log'] #=> #<CodeObject::Function:log @parent=logger …>
    #
    # @overload [](childname)
    #   @param [String, Symbol] childname
    #   @return <Dom::Node>
    #
    # @overload [](path)
    #   @param [String] path The path to the desired node
    #   @return <Dom::Node>
    def [](path)
      return @children[path] if path.is_a? Symbol
      return @children[path.to_sym] if path.split(NS_SEP_STRING).size == 1
      
      path = path.split(NS_SEP_STRING)
      child = @children[path.shift.to_sym]
      
      raise WrongPath.new(path) if child.nil?
      
      # decend recursive
      child[path.join(NS_SEP_STRING)]
    end
    
    # Alias for bracket-access
    # @see #[]
    def find(path)
      self[path]
    end
    
    
    # Returns if the current node is a leaf or not. 
    #
    # @return [Boolean]
    def has_children?
      not (@children.nil? or @children.size == 0)
    end
    
    # Finds all siblings of the current node. If there is no parent, it will 
    # return `nil`.
    #
    # @return [Array<Dom::Node>, nil]
    def siblings
      return nil if parent.nil?
      @parent.children
    end    
      
    
    # Resolves `nodename` in the current context and tries to find a matching
    # {Dom::Node}. If `nodename` is not the current name and further cannot be found in the list of 
    # **children** the parent will be asked for resolution.
    #
    # Given the following example, each query (except `.log`) can be resolved without ambiguity.
    #
    #     # -Core
    #     #   -extend
    #     #   -extensions
    #     #   -logger
    #     #     -log
    #     #   -properties
    #     #   -log
    #
    #     Dom[:Core][:logger].resolve '.log'
    #     #=>  #<CodeObject::Function:log @parent=logger @children=[]> 
    #
    #     Dom[:Core][:logger][:log].resolve '.log'
    #     #=>  #<CodeObject::Function:log @parent=logger @children=[]> 
    #
    #     Dom[:Core][:logger][:log].resolve '.logger'
    #     #=>  #<CodeObject::Object:logger @parent=Core @children=[]> 
    #
    #     Dom[:Core].resolve '.log'
    #     #=>  #<CodeObject::Function:log @parent=Core @children=[]> 
    #
    #     Dom[:Core][:properties].resolve '.log'
    #     #=> #<CodeObject::Function:extend @parent=Core @children=[]> 
    #
    #     Dom[:Core][:logger].resolve 'foo'
    #     #=> nil
    # 
    # @param [String] nodename
    #
    # @return [Dom::Node, nil]
    def resolve(nodename)
      
      return self if nodename == @name
      return nil if @children.nil? and @parent.nil?
      
      path = RELATIVE.match(nodename)
      
      if path        
        first, rest = path.captures
        
        # we did find the first part in our list of children
        if not @children.nil? and @children.has_key? first.to_sym
          
          # we have to continue our search  
          if rest != ""          
            @children[first.to_sym].resolve rest
          
          # Finish
          else
            @children[first.to_sym]
          end
        
        else
          @parent.resolve nodename unless @parent.nil?
        end
        
      # It's absolute?
      elsif ABSOLUTE.match nodename
        Dom.root.find nodename
      end
    end
    
    # Iterates recursivly over all children of this node and applies `block` to them
    #
    # @param [Block] block
    def each_child(&block)
      @children.values.each do |child| 
        yield(child)
        child.each_child(&block) 
      end
    end
    
    
    # @group Manipulation
    
    # There are three different cases
    #   1. Last Childnode i.e. ".foo"
    #      -> Append node as child
    #   2. absolute path i.e. "Foo"
    #      -> delegate path resolution to Dom.root
    #   3. relative path i.e. ".bar.foo"
    #         a. if there is a matching child for first element, delegate
    #            adding to this node
    #         b. create NoDoc node and delegate rest to this NoDoc
    #
    #
    # @overload add_node(path, node)
    #   @param [String] path
    #   @param [Dom::Node] node
    #
    # @overload add_node(node)
    #   @param [Dom::Node] node
    #
    def add_node(*args)      
      
      # Grabbing right overload
      if args.count == 2
        node = args[1]
        path = args[0]        
      elsif args.count == 1
        node = args[0]
                
        path = '.'+node.name
        raise NoPathGiven.new("#{node} has no path.") if path.nil?
      else
        raise ArgumentError.new "Wrong number of arguments #{args.count} for 1 or 2"      
      end      
      
      leaf = LEAF.match path
      
      if leaf
        # node found, lets insert it
        add_child(leaf[:name], node)
        
      else
        matches = RELATIVE.match path
        
        if matches
          name = matches[:first].to_s
          
          # node not found, what to do?
          add_child(name, NoDoc.new(name)) if self[name].nil?
          
          # everything fixed, continue with rest
          self[name].add_node(matches[:rest], node)          
      
        else
          # has to be an absolute path or something totally strange
          raise WrongPath.new(path) unless ABSOLUTE.match path
          
          # begin at top, if absolute
          Dom.add_node '.' + path, node        
        end        
      end      
    end
     
    # @group Name- and Path-Handling
    
    # Like {#qualified_name} it finds the absolute path.
    # But in contrast to qualified_name it will not include the current node.
    #
    # @example  
    #  my_node.qualified_name #=> "Core.logger.log"
    #  my_node.namespace #=> "Core.logger"
    #
    # @see #qualified_name
    # @return [String]
    def namespace
      parents.map{|p| p.name}.join NS_SEP_STRING
    end
  
  
    # The **Qualified Name** equals the **Absolute Path** starting from the
    # root-node of the Dom.
    #
    # @example
    #  my_node.qualified_name #=> "Core.logger.log"
    #
    # @return [String]
    def qualified_name
      parents.push(self).map{|p| p.name}.join NS_SEP_STRING
    end
    
      
    # Generates a text-output on console, representing the **subtree-structure**
    # of the current node. The current node is **not** being printed.
    #
    # @example example output
    #  -Core
    #    -extend
    #    -extensions
    #    -logger
    #      -log
    #    -properties
    #
    # @return [nil]
    def print_tree
    
      # Because parent = nil and parent = Dom.root are handled the same at #parents
      # we need to make a difference here
      if @parent.nil?
        level = 0
      else
        level = parents.count + 1
      end
      
      @children.each do |name, child|
        puts "#{"  " * level}-#{name.to_s}#{' (NoDoc)' if child.is_a? NoDoc}"
        child.print_tree
      end
      nil
    end

    protected
    
    def add_child(name, node)
      
      name = name.to_sym
      
      if self[name].nil?    
        self[name] = node
        
      # If child is a NoDoc: replace NoDoc with node and move all children from
      # NoDoc to node using node.add_child
      elsif self[name].is_a? NoDoc
        self[name].children.each do |name, childnode|
          node.add_child(name, childnode)
        end
        self[name] = node
        
      else
        raise NodeAlreadyExists.new(name)
      end
      
      self[name].parent = self
    end
    
    # @note unimplemented
    def remove_child(name) end 

    def parent=(node)
      @parent = node
    end

    # setting a children of this node
    def []=(name, value)
      @children[name.to_sym] = value
    end  
        
  end
end
