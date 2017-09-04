require "spec_helper"

RSpec.describe CommandLion::Option do
  context "when building an option" do
    let(:opt) { CommandLion::Command.new }
    it "should have an index" do
      opt.index = :example
      expect(opt.index).not_to be nil
    end
    ["description", "type", "delimiter", "default"].each do |atr|
      it "can have a #{atr}" do
        opt.send(atr.to_sym, "example")
        expect(opt.send(atr)).not_to be nil
      end
    end
    #[ "action", "before", "after"].each do
    #end
  end
end
