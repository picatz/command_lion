$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Hello World!"
  version "1.0.0"
  description "Your typical, contrived application example."

  command :rainbow do
    description "STDOUT looks so much better with rainbows."
    flag "--rainbow"
    action do
      require "lolize/auto"
    end
  end

  command :hello do
    description "A simple option to say hello!"
    
    type :string
    flag "hello"
    
    default "world"

    action do
      puts "Hello #{argument}!"
    end
  end
  
  command :hello_multi do
    description "A simple option to say hello to multiple people!"
    
    type :strings
    delimiter ","

    flag "hellos"
    
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
