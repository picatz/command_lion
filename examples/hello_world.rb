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
  end

  command :json do
    flag "--json"
  end
end

