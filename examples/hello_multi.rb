$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Hello People!"
  version "1.0.0"
  description "Your typical, contrived application example."

  command :hello do
    description "A simple option to say hello to multiple people!"
    type :strings
    flag "hello"
    
    default ["bob", "alice"]

    action do
      arguments.each do |argument|
        next if argument == options[:ignore].argument
        puts "Hello #{argument}!"
      end
    end
    
    option :ignore do
      description "Optionally ignore one person."
      flag "--ignore"
      type :string
    end
  end

end
