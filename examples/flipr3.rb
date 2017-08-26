$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

CommandLion::App.run do

  name "Flipr"
  version "1.0.0"
  description "Flipping tables in terminals made easy!"

  command :flip do
    description "Flip a table."
    flag "--flip"

    flips = ["[ ╯ '□']╯︵┻━┻)", "[ ╯ಠ益ಠ]╯彡┻━┻)", "[ ╯´･ω･]╯︵┸━┸)"]

    action do
      options[:count].argument.times do
        puts flips.sample 
      end
    end

    option :count do
      default 3
      description "Specify the number of flips ( default: #{default} )"
      type :integer
      flag "--count"
    end
  end

end
