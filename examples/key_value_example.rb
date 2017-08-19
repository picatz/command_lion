$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

class Example < CommandLion::Base
  key_value :example
end

test = Example.new

test.example[:lol] = "lol"

puts test.example[:lol]

test = Example.build do
  example[:lol] = "lol"
end

puts test.example[:lol]
