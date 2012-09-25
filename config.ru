require File.expand_path("../app/letters_web", __FILE__)

use Rack::ShowExceptions
run LettersWeb.new
