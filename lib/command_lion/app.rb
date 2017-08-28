module CommandLion


  # == DSL Keywords:
  # name::
  #   The name of your application. This is how your application would be referenced in conversation.
  #   It's also going to be used as the defualt banner for the application which will appear at the 
  #   top of the help menu.
  #   
  #   == Example
  #     app = CommandLion::App.build do
  #       name "Example"
  #     end
  #     
  #     app.name?
  #     # => true
  #
  #     app.name = "Changed Name"
  #     # => "Changed Name"
  #
  #     app.name
  #     # => Changed Name
  # usage::
  #   Your usage string can be used to help show the basic information for how to use your application.
  #   You can make this as simple or as complex as you like. One will be generated for you by default
  #   when your application runs, but won't be pre-built for you inside the build block for now.
  #
  #   == Example
  #     app = CommandLion::App.build do
  #       usage "example [commands] [options...]"
  #     end
  #     
  #     app.usage?
  #     # => true
  #
  #     app.usage = <<USAGE
  #         /|
  #     ~~~/ |~
  #     tsharky [command] [switches] [--] [arguments]
  #     USAGE
  #     # => "    /|\n" + "~~~/ |~\n" + "tsharky [command] [switches] [--] [arguments]\n"
  #
  #     app.usage
  #     # => "    /|\n" + "~~~/ |~\n" + "tsharky [command] [switches] [--] [arguments]\n"
  #
  #     puts app.usage
  #     #     /|
  #     # ~~~/ |~
  #     # tsharky [command] [switches] [--] [arguments]
  # description::
  #   To provide further context for your application's existence, it's fairly nice to have a description.
  #   Like, the usage statement, this can be as complex or as simple as you would like. It isn't required either.
  #   
  #   == Example
  #     app = CommandLion::App.build do
  #       description "Example"
  #     end
  #     
  #     app.description?
  #     # => true
  #
  #     app.description = "Changed"
  #     # => "Changed"
  #
  #     app.description
  #     # => Changed
  class App < Base

    def self.default_help(app)
      flagz = app.commands.map do |_, cmd|
        if cmd.flags?
          if cmd.flags.long?
            cmd.flags.short + cmd.flags.long
          else  
            cmd.flags.short
          end  
        elsif cmd.index?
          cmd.index.to_s if cmd.index?
        else
          raise "No flags or index was given!"
        end
      end 
      max_flag = flagz.map(&:length).max + 2
      max_desc = app.commands.values.map(&:description).select{|d| d unless d.nil? }.map(&:length).max
      puts app.name
      if app.version?
        puts
        puts "VERSION"
        puts app.version
      end
      if app.description?
        puts 
        puts "DESCRIPTION"
        puts app.description
        puts
      end
      if app.usage?
        puts
        puts "USAGE"
        puts usage
        puts
      end
      puts "COMMANDS"
      app.commands.values.select { |cmd| cmd unless cmd.is_a? CommandLion::Option }.each do |command|
        if command.flags?
          short = command.flags.long? ? command.flags.short + ", " : command.flags.short
          short_long = "#{short}#{command.flags.long}".ljust(max_flag)
        else
          short_long = "#{command.index.to_s}".ljust(max_flag)
        end
        puts "#{short_long}  #{command.description}"
        if command.options?
          #binding.pry
          command.options.each do |_, option|
            short = option.flags.long? ? option.flags.short + ", " : option.flags.short
            short_long = "  " + "#{short}#{option.flags.long}".ljust(max_flag - 2)
            puts "#{short_long}  #{option.description}"
          end
        end
        puts
      end
    end

    def self.run(&block)
      app = new
      app.instance_eval(&block)
      if ARGV.empty?
        if app.help?
          puts app.help
        else
          default_help(app)
        end
      else
        app.parse
        threadz = false
        app.commands.each do |_, cmd|
          next unless cmd.given?
          if cmd.threaded?
            threadz = [] unless threadz
            threadz << Thread.new do 
              cmd.before.call if cmd.before?
              cmd.action.call if cmd.action?
              cmd.after.call  if cmd.after?
            end
          else
            cmd.before.call if cmd.before?
            cmd.action.call if cmd.action?
            cmd.after.call  if cmd.after?
          end
        end
        threadz.map(&:join) if threadz
      end
    end

    # A tiny bit of rainbow magic is included. You can simple include
    # this option within your application and, if you have the `lolize` gem
    # installed, then rainbows will automagically be hooked to STDOUT to make your
    # application much prettier.
    #
    # It'd be funny if this was turned on by default and you had to opt-out of the 
    # rainbows. Good thing I didn't do that, right?
    def rainbows
      require 'lolize/auto'
    rescue
      raise "The 'lolize' gem is not installed. Install it for rainbow magic!"
    end

    # Simple attributes for the application. Mostly just metadata to help
    # provide some context to the application.
    #
    # * `name` is the name people would refernce your application to in conversation.
    # * `usage` is a simple, optional custom string to provide further context for the app.
    # * `description` allows you to describe what your application does and why it exists.
    # * `version` allows you to do simple version control for your app.
    simple_attrs :name, :usage, :description, :version, :help

    # An application usually has multiple commands.
    #
    # app = CommandLion::App.build
    #   # meta information
    #   
    #   command :example1 do
    #     # more code
    #   end
    #
    #   command :example2 do
    #     # more code
    #   end
    # end
    #
    # app.commands.map(&:name)
    # # => [:example1, :example2]
    def command(index, &block)
      if index.is_a? Command
        cmd = index
      else
        cmd = Command.new
        cmd.index= index
        cmd.instance_eval(&block)
      end
      @commands = {} unless @commands
      @flags = [] unless @flags
      if cmd.flags?
        @flags << cmd.flags.short if cmd.flags.short?
        @flags << cmd.flags.long  if cmd.flags.long?
      elsif cmd.index # just use index
        @flags << cmd.index.to_s
      else
        raise "No index or flags were given to use this command."
      end
      if cmd.options?
        cmd.options.each do |_, option|
          @flags << option.flags.short if cmd.flags.short?
          @flags << option.flags.long  if cmd.flags.long?
          @commands << option
        end
      end
      @commands[cmd.index] = cmd
      cmd
    end

    # Plugin a command.
    def plugin(command)
      command(command)
    end

    # Direct access to the various flags an application has.
    def flags
      @flags
    end

    # Direct access to the various commands an application has.
    def commands
      @commands
    end

    # Parse arguments off of ARGV.
    def parse
      @commands.each do |_, cmd|
        if cmd.flags?
          next unless argv_index = ARGV.index(cmd.flags.short) or ARGV.index(cmd.flags.long)
        else
          next unless argv_index = ARGV.index(cmd.index.to_s)
        end
        cmd.given = true unless argv_index.nil?
        if cmd.type.nil?
          yield cmd if block_given?
        else
          if parsed = parse_cmd(cmd, flags)
            cmd.arguments = parsed || cmd.default
            yield cmd if block_given?
          elsif cmd.default
            cmd.arguments = cmd.default
            yield cmd if block_given?
          end
        end
      end
    end

    # Parse a given command with its 
    def parse_cmd(cmd, flags)
      args = Raw.arguments_to(cmd.flags.short, flags)
      if args.empty?
        args = Raw.arguments_to(cmd.flags.long, flags)
      end
      return nil if args.nil?
      case cmd.type
      when :stdin
        args = STDIN.gets.strip
      when :stdin_stream
        args = STDIN
      when :stdin_string
        args = STDIN.gets.strip
      when :stdin_strings
        args = STDIN.gets.strip
      when :stdin_integer
        args = STDIN.gets.strip.to_i
      when :stdin_integers
        args = []
        while arg = STDIN.gets
          next if arg.nil?
          arg = arg.strip
          parse = arg.to_i
          if parse.to_s == arg
            args << parse
          end
        end
        args
      when :stdin_bool
        args = STDIN.gets.strip.downcase == "true"
      when :single, :string
        args.first
      when :strings, :multi
        if cmd.delimiter?
          if args.count > 1
            args = args.first.split(cmd.delimiter)
            #args = args.first.join.split(cmd.delimiter).flatten.select { |arg| arg unless arg.empty? }
            #args = args.select { |arg| arg if arg.include?(cmd.delimiter) }
            #args = args.map { |arg| arg.split(cmd.delimiter) }.flatten
          else
            args = args.map { |arg| arg.split(cmd.delimiter) }.flatten
          end
        end
        args
      when :integer
        args.first.to_i
      when :integers
        if cmd.delimiter?
          if args.count > 1
            args = args.join
            args = args.select { |arg| arg if arg.include?(cmd.delimiter) }
            args = args.map { |arg| arg.split(cmd.delimiter) }.flatten
          else
            args = args.map { |arg| arg.split(cmd.delimiter) }.flatten
          end
        end
        args.map(&:to_i)
      when :bool, :bools
        if cmd.delimiter?
          if args.count > 1
            args = args.join
            args = args.select { |arg| arg if arg.include?(cmd.delimiter) }
            args = args.map { |arg| arg.split(cmd.delimiter) }.flatten
          else
            args = args.map { |arg| arg.split(cmd.delimiter) }.flatten
          end
        end
        args.map { |arg| arg == "true" }
      end
    rescue => e# this is dangerous
      puts e
      nil
    end

    def run!
      parse do |cmd|
        cmd.action.call
      end 
    end

    if __FILE__== $0
      run!
    end
  end

end
