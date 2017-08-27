$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do
  name "Hello There!"
  version "1.0.0"
  description "A more complex 'hello' application!"
  
  command :hello do
    flag "hello"
    type :strings
    default "world"
    description "Say hello to something! ( default: #{default} )"
    
    action do
      options[:count].argument.times do
        puts "Hello #{argument}!"
      end
    end
    
    option :count do
      description "Change how many times you say hello."
      flag "count"
      type :integer
      default 1
      action do
        abort "Must be a positive integer greater than 1" unless argument >= 1 
      end
    end
  end
  
end
