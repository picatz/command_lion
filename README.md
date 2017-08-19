# 🦁  Command Lion
 
Command-line application framework.

## Installation

    $ gem install command_lion

## Usage

```ruby
require 'command_lion'

CommandLion::App.run do

  name "Rainbow Hello"
  version "1.0.0"
  description "A typical, contrived example application."

  command :hello do
    description "A simple command to say hello!"
    type :string
    flag "hello"
    default "world"

    action do
      puts "Hello #{argument}!"
    end
    
    option :rainbow do
    	description "STDOUT is much prettier with rainbows!"
			flag "--rainbow"
      
			action do
        require 'lolize/auto'
      end
    end
  end

end
```

At the command-line:

```shell
> hello_rainbow
Rainbow Hello

VERSION
1.0.0

DESCRIPTION
A typical, contrived example application.

USAGE
examples/readme.rb [command] [arguments...] [options]

COMMANDS
hello        A simple command to say hello!
  --rainbow  STDOUT is much prettier with rainbows!
> 
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CommandLion project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/command_lion/blob/master/CODE_OF_CONDUCT.md).
