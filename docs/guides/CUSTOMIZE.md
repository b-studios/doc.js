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
If you want to create your own Domain specific language (DSL) it's often not enough to add new tokens
and manipulate the templates. Sometimes you need to create your own custom types of objects. For 
example maybe you could need classes, packages or mixins. So in this example we will create a type
called `class`. 

