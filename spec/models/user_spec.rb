require 'rails_helper'

describe User do
  let(:invalid_username) { "invalid username" }
  let(:valid_username) { "aploshay" }

  describe ".authenticate(username)" do
    it "rejects a nil value" do
      expect(User.authenticate(nil)).to eq false
    end
    it "rejects a blank string" do
      expect(User.authenticate("")).to eq false
    end
    it "rejects an invalid username" do
      expect(User.authenticate(invalid_username)).to eq false
    end
    it "accepts a valid username" do
      expect(User.authenticate(valid_username)).to eq true
    end
  end

  describe ".valid_usernames" do
    subject(:valid_usernames) { User.valid_usernames }
    it "returns usernames" do
      expect(valid_usernames.size).to be > 0
    end
    it "includes valid_username" do
      expect(valid_usernames).to include valid_username
    end
    it "does not include invalid_username" do
      expect(valid_usernames).not_to include invalid_username
    end
  end

  describe ".current_user=" do
    it "sets Thread.current[:current_user]" do
      expect(Thread.current[:current_user]).to be_nil
      User.current_user = "test_user"
      expect(Thread.current[:current_user]).to eq "test_user" 
      Thread.current[:current_user] = nil
    end
  end

  describe ".current_user" do
    it "returns Thread.current[:current_user] if set" do
      Thread.current[:current_user] = "test_user"
      expect(User.current_user).to eq "test_user"
      Thread.current[:current_user] = nil
    end
    it "returns UNAVAILABLE if unset" do
      expect(User.current_user).to eq "UNAVAILABLE"
    end
  end

end
