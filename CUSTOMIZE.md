Areas
=====
To visually group the tokens you can specify an area. All tokens for one area (`:sidebar` in this
example) will be collected and can be rendered in the view-templates with the 
{Helper::Helper#render_tokens render_tokens} helper-method. 

    render_tokens :of => @code_object, :in => :sidebar

While registering a new token you can use any symbol for `area`. Your tokens may not appear in the
rendered html-documentation, unless you explicitly call `render_tokens` for each area.

The default-templates make use of the following areas:

- :body
- :notification
- :sidebar
- :footnote


1. Example - Adding a simple token
==================================
You can extend Doc.js on different levels. The easiest way of customization is to add a simple token.
Let's say we want to add a new innovative token `@requires` to specify dependencies to other objects.

    /**
     * @function say_hello
     * @requires console.log
     */

If we start Doc.js without making any changes to the templates this will result in an error like
**ERROR No Tokenhandler for: @requires**. So let's register our tokenhandler to `tokens/tokens.rb`:

    register :requires
  
  
Changing the area
-----------------  
The token will now be processed using the {Token::Handler :text_only} tokenhandler and will appear
in the `:body` section of the template. Because `requires` may fit much better in the `:sidebar` 
section (it contains meta-information about the object) we place it there with

    register :requires, :area => :sidebar
    
Now our token should be displayed nicely in the sidebar-area on the rightside (depending on which 
template you use).


Using another tokenhandler
--------------------------
While using our new token, we may notice, that it would be nice if we can specify some detailed
information about the dependency like:

    /**
     * @function say_hello
     * @requires console.log for printing the message to the console
     */

So we have to change the tokenhandler to `:named` because our tokenline, now consists of a `name`
and the description-`content`.

    register :requires, :area => :sidebar, :handler => :named
    
The template, which renders the token now can access the `name` and the `content` of the token seperatly
and display them somehow like:

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
markdown and contain links) to html.

Last thing we have to do is to make the renderer use our new template for `@requires` tokens

    register :requires, :area => :sidebar, :handler => :named, :template => 'requires'

2. Example - Writing your own token-handler
===========================================

3. Example - Creating the custom type `class`
=============================================
