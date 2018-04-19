module CommandLion

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
        puts unless app.description?
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
      puts unless app.version? || app.description? || app.usage?
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
          command.options.each do |_, option|
            if option.flags?
              short = option.flags.long? ? option.flags.short + ", " : option.flags.short
              short_long = "  " + "#{short}#{option.flags.long}".ljust(max_flag - 2)
            else
              short_long = "  " + "#{option.index.to_s}".ljust(max_flag - 2)
            end
            puts "#{short_long}  #{option.description}"
          end
        end
        puts
      end
    end


    # The run method will run a given block of code using the
    # Commmand Lion DSL.
    def self.run(&block)
      # Initialize an instance of an App object.
      app = new
      # Evaluate the block of code within the context of that App object.
      app.instance_eval(&block)
      # Parse the application logic out.
      app.parse
      # Sometimes a command-line application is run without being given any arguments.
      if ARGV.empty?
        # Default to a help menu.
        if cmd = app.commands[:help]
          cmd.before.call if cmd.before?
          cmd.action.call if cmd.action?
          cmd.after.call  if cmd.after?
          exit 0
        else
          # Use the default help menu for the application unless that's been
          # explictly removed by the author for whatever reason.
          default_help(app) unless app.default_help_menu_removed?
        end
      else
        app.commands.each do |_, cmd|
          next unless cmd.given?
          cmd.options.each do |_, opt|
            next unless opt.given?
            opt.before.call if opt.before?
            opt.action.call if opt.action?
            opt.after.call  if opt.after?
          end if cmd.options?
          cmd.before.call if cmd.before?
          cmd.action.call if cmd.action?
          cmd.after.call  if cmd.after?
        end
      end
    end

    # Check if there has been an indexed help command.
    def help?
      return true if @commands[:help]
      false
    end

    # Explicitly remove the default help menu from the application.
    def remove_default_help_menu
      @remove_default_help_menu = true
    end

    # Check if the default help menu for the application has been explicitly removed.
    def default_help_menu_removed?
      @remove_default_help_menu || false
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
    # == Example
    #   app = CommandLion::App.build
    #     # meta information
    #     
    #     command :example1 do
    #       # more code
    #     end
    #
    #     command :example2 do
    #       # more code
    #     end
    #   end
    #
    #   app.commands.map(&:name)
    #   # => [:example1, :example2]
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
          if option.flags?
            @flags << option.flags.short if option.flags.short?
            @flags << option.flags.long  if option.flags.long?
          else # just use index
            @flags << option.index.to_s
          end
          @commands[option.index] = option
          #@commands << option
        end
      end
      @commands[cmd.index] = cmd
      cmd
    end

    def help(&block)
      command :help, &block
    end

    # Plugin a command that's probably been built outside of the application's run or build block.
    # This is helpful for sharing or reusing commands in applications.
    # @param command [Command] 
    def plugin(command)
      command(command)
    end

    # Direct access to the various flags an application has. Helpfulp for debugging.
    def flags
      @flags
    end

    # Direct access to the various commands an application has. Helpful for debugging.
    def commands
      @commands.reject { |_, v| v.is_a? CommandLion::Option }
    end

    # Parse arguments off of ARGV.
    #
    # @TODO Re-visit this.
    def parse
      @commands.each do |_, cmd|
        if cmd.flags?
          # or for the || seems to not do what I want it to do...
          next unless argv_index = ARGV.index(cmd.flags.short) || ARGV.index(cmd.flags.long)
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

    # Parse a given command with its given flags. 
    # @TODO Re-visit this.
    def parse_cmd(cmd, flags)
      if cmd.flags?
        args = Raw.arguments_to(cmd.flags.short, flags)
        if args.nil? || args.empty?
          args = Raw.arguments_to(cmd.flags.long, flags)
        end
      else
        args = Raw.arguments_to(cmd.index.to_s, flags)
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
        args = []
        while arg = STDIN.gets
          next if arg.nil?
          arg = arg.strip
          args << arg
        end
        args
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
        args = args.first
      when :strings, :multi
        if cmd.delimiter?
          if args.count > 1
            args = args.first.split(cmd.delimiter)
          else
            args = args.map { |arg| arg.split(cmd.delimiter) }.flatten
          end
        end
        args
      when :integer
        args = args.first.to_i
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
        args = args.map(&:to_i)
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
        args = args.map { |arg| arg == "true" }
      end
    rescue => e# this is dangerous
      puts e
      nil
    end

    def run!
      parse do |cmd|
        next unless cmd.given?
        cmd.options.each do |_, opt|
          next unless opt.given?
          opt.before.call if opt.before?
          opt.action.call if opt.action?
          opt.after.call  if opt.after?
        end if cmd.options?
        cmd.before.call if cmd.before?
        cmd.action.call if cmd.action?
        cmd.after.call  if cmd.after?
      end 
    end

    # Run the application if the file is the main file being run.
    # It's almost kind of narcisitc, if you think about it.
    if __FILE__== $0
      run!
    end
  end

end
