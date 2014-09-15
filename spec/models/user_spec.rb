require 'rails_helper'

describe User do

  describe ".authenticate(username)" do
    it "rejects a nil value" do
      expect(User.authenticate(nil)).to eq false
    end
    it "rejects a blank string" do
      expect(User.authenticate("")).to eq false
    end
    it "accepts any non-blank string" do
      expect(User.authenticate("any non-blank string")).to eq true
    end
  end

end
