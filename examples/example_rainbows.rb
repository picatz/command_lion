$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Rainbow Hello"
  version "1.0.0"
  #rainbows

  command "Say Hello" do
    type :string
    flag "hello"
    default "world"

    action do
      puts "Hello #{argument}!"
    end
  end

end
