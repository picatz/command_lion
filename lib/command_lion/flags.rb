module CommandLion

  # The way a user is able to call or access a command or option for
  # a command-line application is by passing their flags when the application
  # is run at the command-line.
  #
  # == 🗣  DSL 
  # The flags DSL works three different ways.
  # 
  # == Index as Flag
  #   app = CommandLion::Command.build do
  #     command :hello do
  #       # just use the index as the flag
  #     end
  #   end
  # == One Flag
  #   app = CommandLion::Command.build do
  #     command :hello do
  #       flag "--hello"
  #     end
  #   end
  # == Short & Long Flags
  #   app = CommandLion::Command.build do
  #     command :hello do
  #       flags do
  #         short "-e"
  #         long  "--example"
  #       end
  #     end
  #   end
  class Flags < Base
    simple_attrs :short, :long
  end

end
