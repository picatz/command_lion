$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do
  name "Example"
   
  ctrl_c do
    puts "Exiting!"
    exit 0
  end

  command :example do
    action do
      loop { puts "CTL+C to exit!"; sleep 1 }
    end
  end
end
