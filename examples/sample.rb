$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do
  command :example do
    flag "-e"
    type :string
    default "something"
    description "An example command."
    action do
      options[:example].argument.times do
        puts argument
      end
    end

    option :example do
      flag "--count"
      type :integer
      default 1
      description "How many times to print to the screen."
      action do
        abort "Argument must be an integer greater than or equal to 1" unless argument >= 1
      end
    end
  end
end
