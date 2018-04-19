module CommandLion

  # Raw command-line option API
  module Raw

    @arguments = ARGV

    def self.arguments
      return @arguments unless block_given?
      @arguments.each do |argument|
        yield argument
      end
    end

    def self.arguments=(args)
      @arguments = args
    end

    def self.arguments?
      arguments.size > 0 ? true : false
    end

    def self.index_of(flag)
      arguments.index(flag)
    end

    def self.index_of?(flag)
      index_of(flag) ? true : false
    end

    def self.arguments_to(string, flags)
      return if string.nil?
      return if flags.nil?
      if block_given?
        arguments.drop(index_of(string)+1).each do |argument|
          # next if argument == ","
          break if flags.include?(argument)
          yield argument
        end
      else
        args = []
        arguments_to(string, flags) { |arg| args << arg }
        return args
      end
    end

    def self.arguments_to?(flag)
      arguments[arguments.index(flag) + 1] ? true : false
    end
    
    def self.possible_argument_to(string)
      arguments[arguments.index(string) + 1]
    end

    def self.clear!
      @arguments = []
    end

  end

end
