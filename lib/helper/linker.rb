module Helper

  module Linker
  
    FILE = /^file\:(\S+)/
    EXTERNAL = /^((?:http|ftp|https|ssh):\/\/\S+)/
    MAIL = /^(mailto\:\S+)/
    HASH = /^#\S*/
    DOCUMENTATION = /^doc\:([^\s#]+)(#\S+)?/

    # @note link_to - first argument can be
    #   "file:some/path/to_a.file"
    #   "Code.object.path"
    #   ".relative.code_object.path"
    #   "http://external.address.com"
    #   instance_of_code_object
    #
    def link_to(target, text = nil, args = {})
           
      Logger.debug "Trying to link #{target}"
      
      link = if target.is_a? Document::Document
        
        text = target.name if text.nil?     
        to_relative path_to target        
      
      elsif target.is_a? CodeObject::Base
      
        if text.nil? and target.parent == context and context != Dom.root
          text = ".#{target.name}"
          text += "()" if target.is_a? CodeObject::Function
        elsif text.nil?
          text = target.qualified_name
        end
      
        to_relative path_to target
        
      elsif target.match EXTERNAL or target.match MAIL or target.match HASH
        target
        
      elsif target.match FILE
        to_relative target.match(FILE).captures.first
        
      elsif target.match DOCUMENTATION
        Logger.debug target + " matched DOCUMENTATION"
      
        doc_name, hash = target.match(DOCUMENTATION).captures
        obj = Dom.docs.find doc_name        
        text ||= obj.name

        # find relative path to our object and reattach hash to path
        to_relative(path_to obj) + (hash || "") unless obj.nil?        
        
      else        
        # use context dependent resolving functionality as specified in {Tasks::RenderTask}
        obj = resolve target
        to_relative path_to obj unless obj.nil?  
      end
        
      text ||= target 
      
      if link.nil?
        Logger.warn "Could not resolve link to '#{target}'"
        return text 
      end
     
      tag :a, text, :href => link      
    end
    
    def relative_link(path, text)
      tag :a, text, :href => to_relative(path)
    end
    
    # Returns the relative path (from dom) to this node
    # The Node can be either a {CodeObject::Base CodeObject} or a {Document::Document Document}.
    # 
    # @param [CodeObject::Base, Document::Document] object
    #
    # @example 
    #   Dom[:Foo][:bar].file_path #=> Foo/bar
    #   
    def path_to(object, args = {})

      return "" if object.nil? 
      format = args[:format] || :html      
      path = object.parents.push(object).map{|p| p.name}.join('/') + ".#{format.to_s}"
    
      # object can be either a CodeObject or a Document
      # maybe source this one out later on in Configs.some_path
      if object.is_a? CodeObject::Base
        "api/" + path
      else
        "docs/" + path
      end      
    end

    # (see https://github.com/lsegal/yard/blob/master/lib/yard/templates/helpers/html_helper.rb)
    def replace_links(text)
      code_tags = 0
      text.gsub(/<(\/)?(pre|code|tt)|(\\)?\{(?!\})(\S+?)(?:\s([^\}]*?\S))?\}(?=[\W<]|.+<\/|$)/m) do |str|
        closed, tag, escape, name, title, match = $1, $2, $3, $4, $5, $&
        if tag
          code_tags += (closed ? -1 : 1)
          next str
        end
        next str unless code_tags == 0

        next(match[1..-1]) if escape

        next(match) if name[0,1] == '|'
        
        link_to(name, title)
      end
    end
    
    def link_on_page(object)
      if object.is_a? CodeObject::Function
         link_to "#method-#{object.name}", ".#{object.name}()"
      else
        link_to "#object-#{object.name}", ".#{object.name}"
      end
    end
  end
  
end