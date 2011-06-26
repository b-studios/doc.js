module Generator

  class DocsGenerator < Generator
  
    describe     'renders all specified Markdown files to static documentation'
    layout       'application'
    
    start_method :render_docs
    
    protected

    def render_docs
      Dom.docs.each_child do |doc| 
        next if doc.is_a? Dom::NoDoc 
               
        render_document doc        
      end      
      
      readme = Dom.docs.find('README')
      in_context readme do
        @document = readme
        render 'doc_page', :to_file => "index.html"
      end unless readme.nil?
    end

    def render_document(document)       
    
      Logger.info "Rendering Document '#{document.name}'"
      
      in_context document do
        @document = document
        render 'doc_page', :to_file => path_to(document, :format => :html)
      end
    end

  end
end