module CommandLion

	class Command < Base

		simple_attrs :index, :description, :type, 
			:delimiter, :flags, :arguments, 
			:given, :default, :action, 
			:options, :before, :after

    def initialize(&block)
      self.instance_eval(&block) if block_given?
    end

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

	end

end
