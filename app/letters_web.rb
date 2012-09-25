require "sinatra"
require "haml"
require "sass"
require "tilt"
require "compass"

class LettersWeb < Sinatra::Application
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options

  enable :sessions, :logging

  helpers do
    def csrf_token
      Rack::Csrf.csrf_token(env)
    end

    def csrf_tag
      Rack::Csrf.csrf_tag(env)
    end
  end

  get "/" do
    @title = "The tiny debugging library for Ruby"
    @description = "Letters brings Ruby debugging into the 21st century. It leverages print, the debugger, control transfer, even computer beeps to let you see into your code's state."

    response["Cache-Control"] = "max-age=300, public"
    markdown :index, :layout => :layout, :layout_engine => :haml
  end

  get "/api" do
    @title = "The API"
    @description = "Letters lets you debug using these methods -- starting with 'A' and ending with 'Z'."

    response["Cache-Control"] = "max-age=300, public"
    markdown :api, :layout => :layout, :layout_engine => :haml
  end

  get "/ideas" do
    @title = "Ideas"
    @description = "Submit your idea for the next Letters method"

    response["Cache-Control"] = "max-age=300, public"
    haml :ideas
  end
end
