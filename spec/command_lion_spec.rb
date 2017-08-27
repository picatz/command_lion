require "spec_helper"

RSpec.describe CommandLion do
  it "has a version number" do
    expect(CommandLion::VERSION).not_to be nil
  end
end
