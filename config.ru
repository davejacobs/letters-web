require File.expand_path("../app/letters_web", __FILE__)
require "rack/csrf"

# Generated using base64 < /dev/urandom | tr -d "+/\r\n0-9"
use Rack::Session::Cookie, :secret => "LDcEPAxsDExDbpTeLXpnBgRcoPZnRSzEMoPtEaYkNESCHDSUiydjnLwjbJhoQJYM"
use Rack::ShowExceptions
run LettersWeb.new
