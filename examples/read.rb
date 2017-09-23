$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do
  # ...
  command :read_stdin do
    flag "--read"
    type :stdin_stream
    action do
      # Separate into two operations to make it faster.
      if options[:filter].given?
        # Filter lines that contain string.
        inclusive = options[:filter].argument
        arguments do |argument|
          next unless argument.include?(inclusive)
          puts argument
        end
      else
        # Just print lines. 
        arguments do |argument|
          puts argument
        end
      end
    end
    option :filter do
      flag "--filter"
      type :string
    end
  end
end
