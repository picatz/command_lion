$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Printr"

  command :print do
    type :string
    
    action do
      arguments do |argument|
        puts argument 
      end
    end
  end

end
