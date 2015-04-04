root_dir = File.dirname(__FILE__)
app_file = File.join(root_dir, "app/letters_web")
require app_file

use Rack::ShowExceptions
run LettersWeb
