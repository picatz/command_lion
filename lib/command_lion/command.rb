module CommandLion

  # Every command or option for Command Lion is built on the Command class.
  #
  # A Command is typically built using the DSL provided within a build method block:
  # == ⚙️  Build Block
  #   cmd = CommandLion::Command.build do
  #     # ...
  #   end
  # This is used under the hood within an Application's DSL block:
  # == ⚙️  Application Run Block
  #   app = CommandLion::App.build do
  #     command :example_index do
  #       # ...
  #     end
  #   end
  #
  # The DSL keywords are simple methods provided for any Command object and can be accessed
  # or modified outside of the DSL building block itself to, for example, query if it exists.
  #
  # == 🗣  DSL 
  # Command Lion's DSL is meant to be as flexible as possible without being too compelx.
  # 
  # ==⚡️  Example
  #   cmd = CommandLion::Command.build do
  #     index :example
  #     flags do
  #       short "-e"
  #       long  "--example"
  #     end
  #     type :strings
  #     default ["Jim", "Pam", "Dwight", "Michael"]
  #     before do
  #       unless arguments.count > 2
  #         abort "Must provide more than two arguments!"
  #       end
  #     end
  #     action do
  #       arguments.each do |argument|
  #         puts "Hello #{argument}!"
  #       end
  #     end
  #     after do
  #       exit 0
  #     end
  #   end
  #
  # == Keywords 
  # 🔑  description::
  #   To provide further context for your command's existence, it's fairly nice 
  #   to have a description.
  #   
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       description "Example"
  #     end
  #     
  #     cmd.description?
  #     # => true
  #
  #     cmd.description = "Changed"
  #     # => "Changed"
  #
  #     cmd.description
  #     # => Changed
  # 🔑  type::
  #   A command may require a specific argument from the command-line. The type
  #   of argument(s) that the command utilizies can be specified with this keyword.
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       type :string
  #     end
  #     
  #     cmd.type?
  #     # => true
  #
  #     cmd.type = :strings
  #     # => :strings
  #
  #     cmd.type
  #     # => :strings
  # 🔑  default::
  #   To specify a command's default arguments, the default keyword can be used.
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       default "example"
  #     end
  #     
  #     cmd.default?
  #     # => true
  #
  #     cmd.default = "EXAMPLE"
  #     # => "EXAMPLE"
  #
  #     cmd.default
  #     # => "EXAMPLE"
  #
  #     cmd.argument
  #     # => "EXAMPLE"
  # 🔑  delimiter::
  #   In the case of multiple command-line arguments, a custom delimter can be used
  #   to help split up the arguments. Command Lion uses the space betwen arguments as the
  #   default delimter.
  #
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       delimter ","
  #     end
  #     
  #     cmd.delimter?
  #     # => true
  #
  #     cmd.delimter = ":"
  #     # => ":"
  #
  #     cmd.delimter
  #     # => : 
  # 🔑  flag::
  #   If you'd like for one specfic flag to be used for the command, then this keyword is for you!
  #   
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       flag "example"
  #     end
  #     
  #     cmd.flag?
  #     # => true
  #
  #     cmd.flag = "EXAMPLE"
  #     # => "EXAMPLE"
  #
  #     cmd.flag 
  #     # => "EXAMPLE"
  # 🔑  flags::
  #   The flags keywords can be used two specify the short and long flags option for a command.
  #
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       flags do
  #         short "-e"
  #         long  "--example
  #       end
  #     end
  #     
  #     cmd.flags?
  #     # => true
  #
  #     cmd.flags.short? 
  #     # => true
  #
  #     cmd.flags.long? 
  #     # => true
  #
  #     cmd.flags.short = "-E" 
  #     # => "-E"
  #
  #     cmd.flags.long = "--EXAMPLE" 
  #     # => "--EXAMPLE"
  # 
  #     cmd.flags.long
  #     # => "--EXAMPLE"
  #
  #     cmd.flags.short
  #     # => "-E"
  # 🔑  threaded::
  #   To have your command spawn a thread and have the action block
  #   for your command run in its own background thread. 
  #
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       description "Example"
  #     end
  #     
  #     cmd.description?
  #     # => true
  #
  #     cmd.description = "Changed"
  #     # => "Changed"
  #
  #     cmd.description
  #     # => Changed
  # 🔑  action::
  #   What do you want a command to do when it is used? The action keyword can be used
  #   to capture the block you'd like to run when the command is used.
  #
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       action do
  #         puts "Hello World!"
  #       end
  #     end
  #     
  #     cmd.action?
  #     # => true
  #
  #     cmd.action
  #     # => #<Proc:...>
  #
  #     cmd.action.call
  #     # => Hello World! .. to STDOUT
  # 🔑  before::
  #   Before the action block is called, you can specify anouther block to be used beforehand
  #   which can be used to help setup or do some custom error checking.
  #
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       before do
  #         abort "Not on Mondays!" Time.now.monday?
  #       end
  #       action do
  #         puts "Hello World!"
  #       end
  #     end
  #     
  #     cmd.before?
  #     # => true
  #
  #     cmd.before
  #     # => #<Proc:...>
  #
  #     cmd.before.call
  #     # aborts application if it's Monday
  # 🔑  after::
  #   After the action block has been called and completed, anouther optional block
  #   can be used within the block given in the after keyword. This can be used for all sorts
  #   of nifty things: from stopping the application from moving on, to logging, to whatever else.
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       action do
  #         puts "Hello World!"
  #       end
  #       after do
  #         exit 0 
  #       end
  #     end
  #     
  #     cmd.after?
  #     # => true
  #
  #     cmd.after
  #     # => #<Proc:...>
  #
  #     cmd.after.call
  #     # exits application with successful status code
  # 🔑  index::
  #   A command's index should be unique. It is used to used to accesses the command amongst other 
  #   commands when used within an application. However, this keyword usually isn't used unless being utilized
  #   when using Command Lion's plugin system. 
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       index :example
  #     end
  #     
  #     cmd.index?
  #     # => :example
  #
  #     cmd.index
  #     # => :example
  # 🔑  option::
  #   a command may have mutiple sub commands or options associated with it. these effectively
  #   work exactly like any other command, but are just started as a leaf under the paren't command's options.
  #   == Example
  #     cmd = CommandLion::Command.build do
  #       # ...
  #       option :example do
  #         action do
  #           puts "hello world!"
  #         end
  #       end
  #     end
  #     
  #     cmd.options?
  #     # => true
  #
  #     cmd.options[:example]
  #     # => #<proc:...>
  #
  #     cmd.after.call
  #     # exits the application with successful status code
  #
  class Command < Base
    
    simple_attrs :index, :description, :threaded,
                 :type, :delimiter, :flags, :arguments, 
                 :given, :default, :action, 
                 :options, :before, :after
  
    # @private
    def option(index, &block)
      option = Option.new
      option.index = index
      option.instance_eval(&block)
      @options = {} unless @options
      @options[index] = option 
    end

    # @private
    def flags(&block)
      return @flags unless block_given?
      @flags = Flags.build(&block)
    end

    # @private
    def flag(string = nil)
      if string.nil?
        return @flags.short if @flags
        return nil
      end
      @flags = Flags.build do
        short string.to_s
      end
    end
    
    # @private 
    def argument
      if arguments.respond_to?(:each)
        arguments.each do |argument|
          # first
          if block_given?
            yield argument
            return
          else
            return argument
          end
        end
      else
        if block_given?
          yield arguments
          return
        else
          return arguments
        end
      end
      nil
    end

    # @private 
    def arguments
      if block_given?
        if @arguments.respond_to?(:each)
          arguments.each do |argument|
            yield argument
          end
        else
          yield @arguments || @default
        end
      else
        @arguments || @default
      end
    end

    # @private
    def action(&block)
      return @action unless block_given?
      @action = block
    end

    # @private
    def before(&block)
      return @before unless block_given?
      @before = block
    end
    
    # @private
    def after(&block)
      return @after unless block_given?
      @after = block
    end

    # @private
    def threaded
      @threaded = true
    end
  end

end
