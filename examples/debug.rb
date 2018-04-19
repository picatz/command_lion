$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'


cmd = CommandLion.command.new do
  description "This is an example command for debugging!"
  flags do
    short "-e"
    long  "--example"
  end

  before do
    puts "Before"
  end

  action do
    puts "Action"
  end

  after do
    puts "After"
  end

  option :rainbow do
    flags do
      short "-r"
      long  "--rainbow"
    end
    action do
      require 'lolize/auto'
    end
  end
end

binding.pry
