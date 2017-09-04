require "spec_helper"

RSpec.describe CommandLion::Command do
  context "when building a command" do
    let(:cmd) { CommandLion::Command.new }
    it "should have an index" do
      cmd.index = :example
      expect(cmd.index).not_to be nil
    end
    ["description", "type", "delimiter", "default"].each do |atr|
      it "can have a #{atr}" do
        cmd.send(atr.to_sym, "example")
        expect(cmd.send(atr)).not_to be nil
      end
    end
    #[ "action", "before", "after"].each do
    #end
  end
end
