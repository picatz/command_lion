module CommandLion

  # To encapsulate some of the common patterns within Command Lion, there is a Base
  # class which both the App and Command class inhereit from. 
  class Base

    class << self
      # Build up an object with a given block.
      # @param [&block]
      # 
      # == Basic Usage
      #  class Example < CommandLion::Base
      #    simple_attr :example
      #  end
      #
      #  test = Example.build do
      #    example "lol"
      #  end
      #
      #  test.example
      #  # => "lol"
      #
      #  test.example?
      #  # => true
      #
      def build(&block)
        obj = new
        obj.instance_eval(&block)
        obj
      end

      # Quickly spin up an in-memory key-value storage object for the framework.
      #
      # == Basic Usage
      #  class Example < CommandLion::Base
      #    key_value :example
      #  end
      #
      #  test = Example.new
      #  test.example[:lol] = "lol"
      #
      #  test.example[:lol]
      #  # => "lol"
      #
      def key_value(attribute)
        define_method :"#{attribute}" do 
          instance_variable_set(:"@#{attribute}", Hash.new) unless instance_variable_get(:"@#{attribute}")
          instance_variable_get(:"@#{attribute}")
        end
      end

      # This method is important for creating the basic attributes for the framework.
      # @param attribute [Symbol]
      #
      # == Basic Usage
      #  class Example < CommandLion::Base
      #    simple_attr :example
      #  end
      #
      #  test = Example.new
      #
      #  test.example
      #  # => nil
      #
      #  test.example?
      #  # => false
      #
      #  test.example = "lol"
      #  # => "lol"
      #
      #  test.example
      #  # => "lol"
      #
      #  test.example?
      #  # => true
      #
      def simple_attr(attribute)
        define_method :"#{attribute}" do |value = nil|
          return instance_variable_get(:"@#{attribute}") if value.nil?
          instance_variable_set(:"@#{attribute}", value)
        end
        define_method :"#{attribute}=" do |value|
          instance_variable_set(:"@#{attribute}", value)
        end
        define_method :"#{attribute}?" do
          return true if instance_variable_get(:"@#{attribute}")
          false
        end
      end 

      # This method is important for creating multiple basic attributes.
      # @param attribute [Array<Symbol>]
      #
      # == Basic Usage
      #  class Example < CommandLion::Base
      #    simple_attrs :example, :example2
      #  end
      #
      #  test = Example.new
      #
      #  test.example  = "lol"
      #  test.example2 = "lol2"
      #
      def simple_attrs(*attributes)
        attributes.each do |attribute|
          simple_attr(attribute)
        end
      end

    end

  end

end
