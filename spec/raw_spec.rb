require "spec_helper"

RSpec.describe CommandLion do

  before do
    CommandLion.raw.arguments = ["--hello", "world"]
  end

  describe '.arguments' do
    it "will return each raw argument" do
      expect(CommandLion.raw.arguments.count).to equal 2
    end
  end

  describe '.arguments?' do
    it "will check if there were any raw arguments" do
      expect(CommandLion.raw.arguments?).to be true
    end
  end

  describe '.index_of' do
    it "will return the index of the argument in the raw argument list if it exists" do
      expect(CommandLion.raw.index_of("--hello")).to equal 0
      expect(CommandLion.raw.index_of("world")).to equal 1
    end
  end

  describe '.index_of?' do
    it "will return true if the argument in the raw argument list exists" do
      expect(CommandLion.raw.index_of?("--hello")).to be true
      expect(CommandLion.raw.index_of?("world")).to be true
      expect(CommandLion.raw.index_of?("waffles")).to be false
    end
  end

end
