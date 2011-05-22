module Helper

  module Linker
  
    FILE = /^file\:(\S+)/
    EXTERNAL = /^((?:http|ftp|https|ssh):\/\/\S+)/
    MAIL = /^(mailto\:\S+)/

    # @note link_to - first argument can be
    #   "file:some/path/to_a.file"
    #   "Code.object.path"
    #   ".relative.code_object.path"
    #   "http://external.address.com"
    #   instance_of_code_object
    #
    def link_to(target, text = nil, args = {})
      
      text ||= target 
      
      Logger.debug "Trying to link #{target}"
      
      link = if target.is_a? CodeObject::Base
        path_to target
      elsif target.match EXTERNAL or target.match MAIL
        target
      elsif target.match FILE
        to_relative target.match(FILE).captures.first
      else       
        # use context dependent resolving functionality 
        to_relative path_to resolve target
      end      
      
      tag :a, text, :href => link      
    end
    
    # Returns the relative path (from dom) to this node
    # 
    # @example 
    #   Dom[:Foo][:bar].file_path #=> Foo/bar
    #   
    def path_to(object, args = {})
      return "" if object.nil?
      format = args[:format] || :html      
      object.parents.push(object).map{|p| p.name}.join('/') + ".#{format.to_s}"
    end
    
    protected


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

  end
  
end