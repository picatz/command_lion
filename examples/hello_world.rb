$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

app = CommandLion::App.build do

  name "Hello World"
  version "1.0.0"

  command "Hello World" do
    flags do
      short "-hw"
      long  "--hello-world"
    end

    action do
      puts "Hello World!"
    end
  end

end

app.run!
