require "rails_helper"

describe Features::Factory do
  describe "#new" do
    it "returns a specific instance for features with custom fulfillment" do
      factory = Features::Factory.new(user: build_stubbed(:user))
      expect(factory.new(:repository)).to be_kind_of(Features::Repository)
    end

    it "works with string input" do
      factory = Features::Factory.new(user: build_stubbed(:user))
      expect(factory.new("repository")).to be_kind_of(Features::Repository)
    end
  end
end
