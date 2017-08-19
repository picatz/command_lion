$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Rainbow Hello"
  version "1.0.0"
  description "A typical, contrived example application."

  command :hello do
    description "A simple command to say hello!"
    
    type :string
    flag "hello"
    
    default "world"

    action do
      puts "Hello #{argument}!"
    end
    
    option :rainbow do
    	description "STDOUT is much prettier with rainbows!"
      
			flag "--rainbow"
      
			action do
        require 'lolize/auto'
      end
    end
  end

end

