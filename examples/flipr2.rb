$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'pry'

def random_sleep
  sleep (0..5).to_a.sample
end

def synchronize(&block)
  @semaphore ||= Mutex.new
  @semaphore.synchronize do
    block.call
  end
end

CommandLion::App.run do

  name "Flipr"
  version "1.0.0"
  description "Flipping tables in terminals made easy!"

  command :flip do
    threaded
    description "Flip a table."
    flag "--flip"
    flips = ["[ ╯ '□']╯︵┻━┻)", "[ ╯ಠ益ಠ]╯彡┻━┻)", "[ ╯´･ω･]╯︵┸━┸)"]
    action do
      10.times do
        random_sleep
        synchronize { puts flips.sample }
      end
    end
  end

  command :put do
    threaded
    description "Put a table."
    flag "--put"
    puts = ["┬──┬ノ['-' ノ ]", "┬──┬ノ[･ω･ ノ ]", "┬──┬ノ['~' ノ ]"]
    action do
      10.times do
        random_sleep
        synchronize { puts puts.sample }
      end
    end
  end

end
