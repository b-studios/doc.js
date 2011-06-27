module Helper

  # This Helper contains all needed functionality to link to an object, on-page-element or some
  # other urls
  module Linker
  
    FILE = /^file\:(\S+)/
    EXTERNAL = /^((?:http|ftp|https|ssh):\/\/\S+)/
    MAIL = /^(mailto\:\S+)/
    HASH = /^#\S*/
    DOCUMENTATION = /^doc\:([^\s#]+)(#\S+)?/

    # link to can link many types of resources, the `target` can be one of:
    # 
    # - `"file:some/path/to_a.file"`
    # - `"doc:Document.path"`
    # - `"Code.object.path"`
    # - `".relative.code_object.path"`
    # - `"http://external.address.com"`
    # - `"mailto:me@example.com"`
    # - `instance_of_code_object`
    # - `instance_of_a_doc_object`
    # 
    # Most of the time it will be used by {#replace_links} to automatically convert links in 
    # documentation like `{Core.some.object see some.object}`
    #
    # @example
    #   link_to "doc:README", "see readme"
    #   link_to Dom.docs[:README], "see readme"
    # 
    #   link_to "file:pdf/information.pdf", "pdf-file (1.5MB)"
    #   link_to "http://b-studios.de", "b-studios"
    # 
    # @param [String, Document::Document, CodeObject::Base] target for further information see above
    # @param [String] text the link text
    # @return [String] a html-link
    # @param [Hash] args the arguments, which will be reached through to {Helper#tag}
    def link_to(target, text = nil, args = {})
           
      Logger.debug "Trying to link #{target}"
      
      link = if target.is_a? Document::Document
        
        text = target.name if text.nil?     
        to_relative path_to target        
      
      elsif target.is_a? CodeObject::Base
      
        if text.nil? and target.parent == context and context != Dom.root
          text = target.display_name
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
        unless obj.nil?
          to_relative path_to obj
        else
          nil
        end  
      end
        
      text ||= target 
      
      if link.nil?
        Logger.warn "Could not resolve link to '#{target}'"
        return text 
      end
      
      tag :a, text, args.merge({ :href => link })      
    end
    
    # Creates a link, relative to the current output-path
    #
    # @example
    #   relative_link '/home/me/output/test.html', 'Click me'
    #   #=> "<a href='../test.html'>Click me</a>"
    #
    # @param [String] path absolute path to the resource
    # @param [String] text the link text
    # @return [String] html-link
    def relative_link(path, text)
      tag :a, text, :href => to_relative(path)
    end
    
    # Returns the relative path (from dom) to this node
    # The Node can be either a {CodeObject::Base CodeObject} or a {Document::Document Document}.
    #
    # @note this method can be overwritten in every included Helper to fit your custom API-Layout
    # 
    # @param [CodeObject::Base, Document::Document] object
    #
    # @example 
    #   Dom[:Foo][:bar].file_path                 #=> Foo/bar.html
    #   Dom['Foo.bar'].file_path :format => :json #=> Foo/bar.json
    #   
    def path_to(object, args = {})

      return "" if object.nil?
      format = args[:format] || :html      
      path = object.parents.push(object).map{|p| p.name}.join('/') + ".#{format.to_s}"
    
      # object can be either a CodeObject or a Document
      # maybe source this one out later on in Configs.some_path
      if object.is_a? CodeObject::Base
        "api/" + path
      elsif object.is_a? Document::Document
        "docs/" + path
      else
        Logger.warn "Could not resolve link to '#{object}'"
        object.to_s
      end   
    end
    
    # finds any links, that look like `{my_link}` and replaces them with the help of {#link_to}
    #
    # @example
    #   replace_links "This is a text, containing a {some.reference link}"
    #   #=> "This is a text, containing a <a href='../some/reference.html'>link</a>"
    #
    # @param [String] text
    # @return [String] text containing html-links
    #
    # @see https://github.com/lsegal/yard/blob/master/lib/yard/templates/helpers/html_helper.rb#L170
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
  end  
end
