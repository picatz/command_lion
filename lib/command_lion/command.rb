module CommandLion

  class Command < Base
    
    simple_attrs :name, :usage, :description, :threaded,
                 :type, :delimiter, :flags, :arguments, 
                 :given, :default, :action, 
                 :options, :before, :after
    
    def option(name, &block)
      option = Option.new
      option.name = name
      option.instance_eval(&block)
      @options = {} unless @options
      @options[name] = option 
    end

    def flags(&block)
      return @flags unless block_given?
      @flags = Flags.build(&block)
    end

    def flag(string = nil)
      if string.nil?
        return @flags.short if @flags
        return nil
      end
      @flags = Flags.build do
        short string.to_s
      end
    end
    
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

    def action(&block)
      return @action unless block_given?
      @action = block
    end

    def before(&block)
      return @before unless block_given?
      @before = block
    end
    
    def after(&block)
      return @after unless block_given?
      @after = block
    end

    def threaded
      @threaded = true
    end
  end

end
