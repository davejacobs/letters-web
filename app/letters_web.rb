require "sinatra"
require "haml"
require "sass"
require "tilt"
require "compass"

class LettersWeb < Sinatra::Application
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options

  enable :sessions, :logging

  get "/" do
    response["Cache-Control"] = "max-age=300, public"
    haml :layout, {},
      :content => markdown(:index), 
      :title => "The tiny debugging library for Ruby",
      :description => "Letters brings Ruby debugging into the 21st century. It leverages print, the debugger, control transfer, even computer beeps to let you see into your code's state."
  end

  get "/api" do
    response["Cache-Control"] = "max-age=300, public"
    haml :layout, {},
      :content => markdown(:api), 
      :title => "The API",
      :description => "Letters lets you debug using these methods -- starting with 'A' and ending with 'Z'"
  end
end
