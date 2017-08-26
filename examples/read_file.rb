$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "File Readr"

  command :read do
    description "Read the lines from a given file back to the screen."
    flag "--read"
    type :string
    
    action do
      IO.foreach(argument) do |line|
        print line
      end 
    end
  end

end
