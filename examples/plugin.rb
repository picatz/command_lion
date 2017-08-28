$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

cmd = CommandLion::Command.build do
  index :example
  description "An example, could you guess?"
  action do
    puts "Works!"
  end
end

cmd2 = CommandLion::Command.build do
  index :example2
  description "Anouther example, could you guess?"
  action do
    puts "Works like a charm!"
  end
end

CommandLion::App.run do
  name "Plugin Example"
  description "A simple application that uses command lion's plugin command system."
  plugin cmd
  plugin cmd2
end
