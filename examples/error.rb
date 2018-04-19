$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do
  name "Hello World"

  command :hello_world do
    flag "--hello-world"
    action do
      puts "Hello World!"
    end
    option :example do
      flag "--example"
      action do
        puts "Example worked!"
      end
    end
  end
end
