require "command_lion/version"
require "command_lion/raw"
require "command_lion/base"
require "command_lion/command"
require "command_lion/option"
require "command_lion/flags"
require "command_lion/app"

module CommandLion
  def self.raw
    Raw
  end

  def self.command
    Command
  end

  def self.application
    Application
  end
end
