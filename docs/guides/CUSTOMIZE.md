Customization
=============
All of the following Guides require modifications of the default-templates. To start of with your own
templates simply type:

    docjs scaffold TEMPLATE_PATH
    
in your console and replace `TEMPLATE_PATH` with the path you wish the templates to be generated in.
This command will copy the default templates to `TEMPLATE_PATH`, which results in a structure similiar
to:

    my_templates/
      generators/
      helpers/
      resources/
      tokens/
      types/
      views/
      application.rb
      
If you take a look at `application.rb` you will see, that all it does is to require the files, which 
are placed within the other template-folders.

generators/
-----------
Contains all custom generators, which are needed to create html or json-files from the internal data-
structure. In section {file:CUSTOMIZE.md#Modifying_a_Generator Modifying a Generator} you can learn
a bit more about the use of a generator and how to customize it.

**Contents:**

  - {Generator::ApiIndexGenerator}
  - {Generator::ApiPagesGenerator}
  - {Generator::DocsGenerator}
  - {Generator::JsonGenerator}

helpers/
--------
Helpers are, like helpers in Rails, included into your generator and can be used there and in the views
aswell. (See Section Helpers in {Generator::Generator})

**Contents:**

  - {Helper::Template}

resources/
----------
Contains all static template resources like **css**, **js** and **img** files

**Contents:**

  - `css/application.css`
  - `scss/application.scss` and all partials (starting with an underscore)
  - `js/application.js` and all required libraries
  - `img/object.png` and all other icons

tokens/
-------
Only consists of one file `tokens.rb`, which contains all the registered Tokens. You may find some more 
information about the tokens in the {file:USE.md Usage-Guide}.

**Contents:**

  - `tokens.rb`

types/
------
Types are special tokens. They categorize the Comments respectively CodeObject's by subclassing them.
Per default these are

**Contents:**

  - {CodeObject::Object} (@object)
  - {CodeObject::Function} (@function, @constructor, @method)
  - {CodeObject::Prototype} (@prototype)

See {file:USE.md#Types Usage-Guide}

views/
------
Contains the `html.erb` template-files and partials, which will be rendered by the {Generator::Generator Generators}

**Contents:**

  - `function/` All templates to render {CodeObject::Function @function-documentation}
  - `object/` All templates to render {CodeObject::Object @object-documentation}
  - `layouts/` Contains all layouts like `application.html.erb` and `json.html.erb`
  - `tokens/` All templates, which a necessary to render a token (See {file:CUSTOMIZE.md#Creating_a_custom_template the Guide below})


1. Example - Adding a simple token
==================================
You can extend Doc.js on different levels. The easiest way of customization is to add a simple token.
Let's say we want to add a new innovative token `@requires` to specify dependencies to other objects.

    /**
     * @function say_hello
     * @requires console.log
     */

If we start Doc.js without making any changes to the templates this documentation will result in an 
error like **ERROR No Tokenhandler for: @requires**. 
So let's register our tokenhandler to `tokens/tokens.rb`:

    register :requires
  
  
Changing the area
-----------------  
The token will now be processed using the {Token::Handler :text_only} tokenhandler and will appear
in the `:body` section of the template. Because `requires` may fit much better in the `:sidebar` 
section (it contains meta-information about the object) we place it there with

    register :requires, :area => :sidebar
    
Now our token should be displayed nicely in the sidebar-area on the right side (if you are using the
default template).

You can find more information about areas in {Helper::Helper#render_tokens the Helper-doc}


Using another tokenhandler
--------------------------
While using our new token, we may notice, that it would be nice if we can specify some detailed
information about the dependency like:

    /**
     * @function say_hello
     * @requires console.log for printing the message to the console
     */

So we have to change the tokenhandler to `:named` because our tokenline now consists of a `name`
and the description-`content`.

    register :requires, :area => :sidebar, :handler => :named
    
The template, which renders the token now can access the `name` and the `content` of the token 
seperatly and displays them somehow like:

    <h4>console.log</h4>
    <p>for printing the message to the console</p>


Creating a custom template
--------------------------
We've come pretty far with just adding one line to our own templates. But now we want to use our own
template for this token, because the title isn't automatically linked, if the required object exists
in our documentation. Because this would be a cool features, let's implement it.

First of all we have to create our partial. Like all other templates, the token-partials are located 
under `views/tokens`. So we create a file called `views/tokens/_requires.html.erb` and fill in some
content:

    <section>
      <h3>Dependencies</h3>
      <ul>
        <% tokens.each do |token| %> 
          <li>
            <h4><%=link_to token.name %></h4>
            <%=to_html token.content %>
          </li>
        <% end %>
      </ul>
    </section>
    
Because all tokens of one type are rendered as a collection by default, we have to iterate over our
local-variable `tokens`. We use the {Helper::Linker#link_to link_to} helper to create a link to the
referenced dependency if it exists in our documentation. Additionally we use the 
{Helper::Helper#to_html to_html} helper to convert the description (which could be written using
markdown and contain links we need to generate) to html.

Last thing we have to do, is to make the renderer use our new template for `@requires` tokens

    register :requires, :area => :sidebar, :handler => :named, :template => :requires


2. Example - Writing your own token-handler
===========================================
There are a {Token::Handler few handlers}, which can be used to process the tokenlines. But sometimes
one of the existing handlers isn't enough to process your token.

Let's say we need a tokenhandler to parse something like

    /**
     * @special [String] my_name (default) description
     */

We could get pretty close using the :typed_with_name handler. But this handler doesn't recognizes
defaults, so we need to write our own handler.

First of all we register our token in `tokens/tokens.rb`.

    register :special do |tokenklass, content|
      # currently the textual content is only stored as `content`
      self.add_token token_klass.new(:content => stringcontent)
    end
    
Next let's write a Regexp, that recognizes our parts. (Ok, that regular expression may not be the
most beautiful one, but it may work)
    
    register :special do |token_klass, content|
    
      TYPED_NAMED_WITH_DEFAULTS = /\[([^\]\n]+)\]\s*([\w_.:]+)\s(?:\(([^\)]+)\))?\s*(.*)/
      
      types, name, default, content = TYPED_NAMED_WITH_DEFAULTS.match(content).captures
      token = token_klass.new(:name => name, :types => types.split(','), :content => content)
      token.define_singleton_method(:default) { default }
      
      self.add_token token
    end
    
Because :default isn't a default property of token, we have to add it manually by defining a
method which returns the value (`define_singleton_method`).

The last thing, we would have to do is to create a custom template and use it. See 
{file:CUSTOMIZE.md#Creating_a_custom_template above} for tipps how to achieve this.
The template could make use of `token.default` to access the default value parsed by our cool
token-handler.

3. Example - Creating the custom type `class`
=============================================
If you want to create your own Domain specific language (DSL) it's often not enough to add new 
tokens and manipulate the templates. Sometimes you need to create your own custom types of objects. 
For example maybe you could need classes, packages or mixins. So in this example we will create a 
type called `class`. 

The template-folder `types/` contains 3 items by default:

    types/
      function.rb
      object.rb
      prototype.rb

We will create a fourth one and call it `class.rb`, which at first only consists of 

    class CodeObject::Class < CodeObject::Base
    end
    
Then we need to `require` it from `application.rb`

    require_relative 'types/class.rb'
    
We get serious problems here, because in ruby we cannot redefine `Class` without getting into 
troubles. With nearly all other Type-Names everything wents fine, but for `Class` we need something 
different. Maybe we can simply call it `Klass` or `ClassType` to bypass any trouble. It's up to you.

    class CodeObject::Klass < CodeObject::Base
    end

Based on the name you choosed, we now have to register our token, to be a Type-Creating Token.
Every Comment needs exactly one of these type-specificating tokens. With the following line (either
in `tokens.rb` or in `class.rb`, after defining our type) we make our token work:

    Token::Handler.register :class, :type => CodeObject::Klass
    
Using `@class` in a comment will create an instance of CodeObject::Klass and fill it with all 
details of that comment.

If we don't want our type-token to appear in any token-listing like :body or :sidebar we can 
specify :none for the rendering-area.

    Token::Handler.register :class, :type => CodeObject::Klass, :area => :none

If we test our customized template with something like

    /** 
     * @class Collection
     */
    var Collection = function() { ... };
    Collection.prototype = Array.prototype;
    
we may notice, that nothing is really different from using `@object` instead. That's only because
our template is not yet specialised to work with classes.

Modifying a Generator
---------------------
We learned how to create our own templates. But now we need to switch between different templates
before rendering starts. To understand where rendering starts, we need to inspect the generators.
{Generator::Generator Generators} in Doc.js are pretty much like `Controllers` in Rails. They
decide which template to use and where to save the result. So let's take a look at the
{Generator::ApiPagesGenerator generators/api_pages_generator.rb}. We can see that every generator
is able to choose which layout it want's to render the pages in.

We may notice, that the ApiPagesGenerator is nothing more than a switch for CodeObject-Types. By
default it only differs between {CodeObject::Function functions} and those, that are not functions.

We can add some code, to use own templates for classes.

    Dom.root.each_child do |node| 
      next if node.is_a? Dom::NoDoc 
        
      if node.is_a? CodeObject::Function
        render_function node
      elsif node.is_a? CodeObject::Klass
        render_class node
      else
        render_object node
      end
    end

We invoke a method, which is not yet defined '`render_class`'. This method get's the node as the
only parameter and needs to create html-output from it.

    def render_class(code_object)       
    
      Logger.info "Rendering Class: '#{code_object.name}'"
      
      # This is needed to eventually resolve relative links included in the documentation
      in_context code_object do
        
        # The instance-variables are also available in the template-views
        @class = code_object
        @methods = @object.children.values.select {|c| c.is_a? CodeObject::Function }
        
        # Here we call our new template, stored under `views/class/index.html.erb`
        render 'class/index', :to_file => path_to(code_object, :format => :html)
      end
    end
    
The last thing (and granted, this may be the biggest part) is to create a template, which is 
optimzed regarding our new type `class`.

Combination with a custom handler
---------------------------------
Often classes are used in context of the classical inheritance. Once class extends another.
So we may add a new token `@extends`, which is a text-only token-handler, maybe with a custom 
template. (See first example above)

It would be much more interesting to add a documentation syntax like:

    /**
     * @class Student < Person
     */
     
This is way easiert, than it may look like at first glance. We only have to write a custom handler:

    Token::Handler.register :class, :type => CodeObject::Klass, :area => :none do |tokenklass, content|
      extends = /\s*[^\s]+\s*(?:<\s*([^\s]+))/.match(content)
      
      self.add_token Token::Token::ExtendsToken.new(:content => extends.captures.first) unless extends.nil?
    end
    
What is this doing? We first match our token-content against a regular expression like `(Word (< Word)?)`
the inner word is captured. If this matches we use the second part (after the `<`) to create an 
`@extends` token.
