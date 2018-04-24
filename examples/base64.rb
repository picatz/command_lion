$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "command_lion"
require "base64"

CommandLion::App.run do
  name "base64"
  version "1.0.0"
  description "base64 encoder and decoder"

  command :encode do
    description "Base64 encode a given string."
    type :string
    action do
      puts Base64.encode64(argument).strip
    end
  end

  command :decode do
    description "Base64 decode a given string."
    type :string
    action do
      puts Base64.decode64(argument)
    end
  end
end
