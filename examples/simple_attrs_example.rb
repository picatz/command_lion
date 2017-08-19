$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

class Example < CommandLion::Base
  simple_attrs :example1, :example2
end

test = Example.build do
  example1 "lol"
  example2 "lol"
end

test.example1?
# => true

test.example2?
# => true

puts test
