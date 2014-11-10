require "rails_helper"

describe SessionsHelper do
  describe "#signed_in?" do
    it "returns false until user has signed in" do
      expect(helper.signed_in?).not_to be
    end
  end
  describe "SessionInfoModule methods:" do
    describe "::current_username" do
      it "returns UNAVAILABLE if session value missing" do
        expect(SessionInfoModule.current_username).to eq "UNAVAILABLE"
      end
      it "returns signed-in username if available" do
        SessionInfoModule.session = { username: "Test username" }
        expect(SessionInfoModule.current_username).to eq "Test username"
        SessionInfoModule.session = nil
      end
    end
  end
end
