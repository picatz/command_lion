module CommandLion


  # The Command class is a fundatmental class for Command Lion. 
  #
  # What's kind of nice about it -- at least, I hope -- is that it's actually
  # a very simple class. The `Option` class for Command Lion literally just inhereits from
  # this class so that a Command's options has a specfic namespace, but basically works
  # identically in every other way. This allows you to work out the options for your command
  # in a very simple node-leaf representation. This allows you to naturally work your way down
  # and up the tree as nessecary.
  #
  # Because most of the "keywords" for Command Lion, which are simply ruby methods that behave
  # in a particular way for the Command Lion DSL.
  #
  # == DSL Keywords:
  # description::
  #   To provide further context for your application's existence, it's fairly nice to have a description.
  #   Like, the usage statement, this can be as complex or as simple as you would like. It isn't required either.
  #   
  #   == Example
  #     app = CommandLion::Command.build do
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
  # threaded::
  #   To have your command spawn a thread and have the action block
  #   for your command run in its own background thread. 
  #
  #   == Example
  #     app = CommandLion::Command.build do
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
  #
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
