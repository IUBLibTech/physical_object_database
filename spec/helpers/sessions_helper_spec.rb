require "rails_helper"

describe SessionsHelper do
  describe "#signed_in?" do
    it "returns false until user has signed in" do
      expect(helper.signed_in?).not_to be
    end
  end
end
