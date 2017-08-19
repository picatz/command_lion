$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

class Example < CommandLion::Base
  simple_attr :example
end

test = Example.build do
  example "lol"
end

test.example
# => "lol"

test.example?
# => true

puts test
