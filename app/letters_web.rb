require "sinatra"
require "sinatra/assetpack"
require "haml"
# require "sass"
# require "tilt"

class LettersWeb < Sinatra::Application
  set :haml, { :format => :html5 }

  register Sinatra::AssetPack
  assets do
    css :application, [
      "/stylesheets/style.css"
    ]

    css_compression :sass

    js :application, [
      "/javascripts/**/*.js"
      # "/javascripts/sh/*.js"
    ]

    js_compression :jsmin

    serve "/stylesheets", :from => "assets/stylesheets"
    serve "/javascripts", :from => "assets/javascripts"
    serve "/images", :from => "assets/images"
  end

  get "/" do
    @title = "The tiny debugging library for Ruby"
    @description = "Letters brings Ruby debugging into the 21st century. It leverages print, the debugger, control transfer, even computer beeps to let you see into your code's state."

    response["Cache-Control"] = "max-age=300, public"
    markdown :index,
      :layout => :layout,
      :layout_engine => :haml,
      :smart => true
  end

  get "/api" do
    @title = "The API"
    @description = "Letters lets you debug using these methods -- starting with 'A' and ending with 'Z'."

    response["Cache-Control"] = "max-age=300, public"
    markdown :api,
      :layout => :layout,
      :layout_engine => :haml,
      :smart => true
  end

  get "/resources" do
    @title = "Resources"
    @description = "Look no further for help with Letters"

    response["Cache-Control"] = "max-age=300, public"
    markdown :resources,
      :layout => :layout,
      :layout_engine => :haml,
      :smart => true
  end
end
