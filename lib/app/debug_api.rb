require 'sinatra'
require 'tilt/erb'
require 'util/ize'

module Todo
  class DebugApi < Sinatra::Base

    enable :inline_templates

    before do
      content_type :"text/html"

      @nav_route_map = {
        :root => url(''),
        :request => url('request'),
        :request_env => url('request/env'),
        :request_paths => url('request/path'),
        :params => url('params'),
        :env => url('env')
      }
    end

    get '/' do
      render_erb :root
    end

    get '/request' do
      pre = request.class.public_instance_methods.sort.map { |r| r.to_s }.join("\n")
      render_erb :request, pre
    end

    get '/request/path' do
      paths = {
        :path => request.path,
        :path_info => request.path_info,
        :fullpath => request.fullpath
      }
      pre = paths.sort.map do |pair|
        pair.to_s
      end.join "\n"
      render_erb :request, pre
    end

    get '/request/env' do
      pre = request.env.sort.map { |e| e.to_s }.join("\n")
      render_erb :request, pre
    end

    get '/params' do
      pre = params.sort.map { |p| p.to_s }.join("\n")
      render_erb :request, pre
    end

    get '/env' do
      pre = ENV.sort.map { |pair| pair.to_s }.join("\n")
      render_erb :request, pre
    end

    private
    def render_erb(subtitle, preformatted_text="")
      erb :pre, :locals => {
            :nav => @nav_route_map.map { |name, url| [Ize.titleize(name), url] },
            :subtitle => subtitle.to_s.capitalize,
            :pre => preformatted_text
          }
    end

  end
end

__END__
@@ layout
<!doctype html>
<html>
<head>
<style type="text/css">
  body {
    position: absolute;
    top: 0;
    bottom: 0;
    font-family: verdana, arial, sans-serif;
    margin: 0;
  }

  #container {
    position: relative;
    display: flex;
    width: 100%;
    height: 100%;
  }

  #left {
    position: relative;
    height: 100%;
  }

  #left,
  #left-container {
    width: 250px;
  }

  #left-container {
    position: fixed;
    height: 100%;
    background-color: #eee;
    border-right: 1px solid #ccc;
  }

  #left-container > * {
    padding: 0 10px;
  }

  #nav a {
    display: block;
    padding: 5px 0;
    font-size: 1.2rem;
    color: #6E79A3;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
  }

  #content {
    padding: 0 10px;
  }
</style>
</head>
<body>

  <div id="container">
    <div id="left">
      <div id="left-container">
        <h1>Todo Debug</h1>
        <div id="nav">
          <% nav.each do |name, url| %>
          <a title="<%= name %>" href="<%= url %>"><%= name %></a>
          <% end %>
        </div>
      </div>
    </div>

    <div id="content">
      <h2><%= subtitle %></h2>
      <%= yield %>
    </div>
  </div>

</body>
</html>

@@ pre
<pre><%= pre %></pre>
