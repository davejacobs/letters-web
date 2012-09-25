require File.expand_path("../app/letters_web", __FILE__)
require "rack/cache"

use Rack::ShowExceptions
use Rack::Cache,
  :verbose => true, 
  :metastore => "heap:cache/meta",
  :entitystore => "heap:cache/body"

run LettersWeb.new
