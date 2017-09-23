$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Printr"
  version "1.0.0"
  remove_default_help_menu

  command :print do
    type :string
    
    action do
      arguments do |argument|
        puts argument 
      end
    end
  end

  #help do
  #  flags do
  #    short "-h"
  #    long  "--help"
  #  end
  # 
  #  action do
  #    puts "So helpfulp!"
  #  end 
  #end

end
