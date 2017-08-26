$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Readr"

  command :read do
    description "Stream arguments read from STDIN back to the screen."
    flag "--read"
    type :stdin_stream
    
    action do
      arguments do |argument|
        puts argument
      end
    end
  end

end
