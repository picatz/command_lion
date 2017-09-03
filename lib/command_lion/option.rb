module CommandLion

  # The Option class is a direct sub-class of the Command class. In pretty much
  # every way it is just a command under the hood. However, instead of being indexed
  # in an application's commands index, it will be available in whatever command's
  # options index.
  #
  # == Example
  #
  #   app = CommandLion::App.build do
  #     command :example_command do
  #         # ...
  #       option :example_option do
  #         # ...
  #       end
  #     end
  #   end
  #
  #   app.commands[:example_command].options[:example_option]
  class Option < Command; end
end
