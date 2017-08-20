$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'


CommandLion::App.run do

  name "Flipr"
  version "1.0.0"
  description "Flipping tables in terminals made easy!"

  command :flip do
    description "Flip a table."
    
    flips = ["[ ╯ '□']╯︵┻━┻)", "[ ╯ಠ益ಠ]╯彡┻━┻)", "[ ╯´･ω･]╯︵┸━┸)"]
    
    flags do
      short "-f"
      long  "--flip"
    end
    
    action do
      puts flips.sample
    end
  end

end
