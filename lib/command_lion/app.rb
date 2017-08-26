module CommandLion

  class App < Base

    def self.default_help(app)
      flagz = app.commands.map do |cmd|
        if cmd.flags.long?
          cmd.flags.short + cmd.flags.long
        else  
          cmd.flags.short
        end  
      end 
      max_flag = flagz.map(&:length).max + 2
      max_desc = app.commands.map(&:description).select{|d| d unless d.nil? }.map(&:length).max
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
      end
      if app.usage?
        puts
        puts usage
        puts
      else
        puts
        puts "USAGE"
        puts "#{$PROGRAM_NAME} [command] [arguments...] [options]"
        puts
      end
      puts "COMMANDS"
      app.commands.select { |cmd| cmd unless cmd.is_a? CommandLion::Option }.each do |command|
        short = command.flags.long? ? command.flags.short + ", " : command.flags.short
        short_long = "#{short}#{command.flags.long}".ljust(max_flag)
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
        app.commands.each do |cmd|
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
    def command(name, &block)
      cmd = Command.new
      cmd.name = name
      cmd.instance_eval(&block)
      @commands = [] unless @commands
      @flags = [] unless @flags
      @flags << cmd.flags.short if cmd.flags.short?
      @flags << cmd.flags.long  if cmd.flags.long?
      if cmd.options?
        cmd.options.each do |_, option|
          @flags << option.flags.short if cmd.flags.short?
          @flags << option.flags.long  if cmd.flags.long?
          @commands << option
        end
      end
      @commands << cmd
      cmd
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
      @commands.each do |cmd|
        next unless index = ARGV.index(cmd.flags.short) or ARGV.index(cmd.flags.long)
        cmd.given = true
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
      case cmd.type
      when :stdin
        args = STDIN.gets.strip
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
          args << arg.strip.to_i
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
      binding.pry
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
