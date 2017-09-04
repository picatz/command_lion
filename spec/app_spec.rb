require "spec_helper"

RSpec.describe CommandLion::App do
  context "when building an app" do
    let(:app) { CommandLion::App.new }
    ["description", "usage", "name", "version"].each do |atr|
      it "can have a #{atr}" do
        app.send(atr.to_sym, "example")
        expect(app.send(atr)).not_to be nil
      end
    end
    #[ "action", "before", "after"].each do
    #end
  end
end
