module CommandLion

  module Raw

    def self.index_of(string)
      ARGV.index(string)
    end

    def self.arguments_to(string, flags)
      return unless index_of(string)
      args = []
      ARGV.drop(index_of(string)+1).each do |argument|
        next if argument == ","
        break if flags.include?(argument)
        args << argument
        yield argument if block_given?
      end
      args
    end

    def self.arguments_to?(string)
      ARGV[ARGV.index(string) + 1]
    end
    
    def self.argument_to(string)
      ARGV[ARGV.index(string) + 1]
    end

  end

end
