describe User do
  # users are seed data and must be manually deleted
  let(:user) { FactoryGirl.create :user }
  let(:valid_user) { FactoryGirl.build :user }
  let(:invalid_user) { FactoryGirl.build :user, :invalid }

  let(:invalid_username) { "invalid username" }
  let(:valid_username) { "web_admin" }

  describe "FactoryGirl" do
    specify ":valid_user is valid" do
      expect(valid_user).to be_valid
    end
    specify ":invalid_user is invalid" do
      expect(invalid_user).not_to be_valid
    end
  end

  describe "should be seeded with data" do
    specify "18 values" do
      expect(User.all.size).to be >= 18
    end
  end

  describe "has required fields:" do
    specify "name" do
      valid_user.name = ""
      expect(valid_user).not_to be_valid
    end
    specify "username" do
      valid_user.username = ""
      expect(valid_user).not_to be_valid
    end
  end

  describe "has role fields:" do
    User::ROLES.each do |role|
      specify "#{role}" do
        expect(valid_user).to respond_to role
      end
    end
  end

  describe "has unique fields:" do
    # user is seed data and must be manually destroyed in tests
    before(:each) { user }
    after(:each) { user.destroy }
    specify "unique name" do
      duplicate_user = FactoryGirl.build :user, name: user.name
      expect(duplicate_user).not_to be_valid
    end
    specify "unique username" do
      duplicate_user = FactoryGirl.build :user, username: user.username
      expect(duplicate_user).not_to be_valid
    end
  end

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

  describe ".current_username=" do
    it "sets Thread.current[:current_username]" do
      expect(Thread.current[:current_username]).to be_nil
      User.current_username = "test_user"
      expect(Thread.current[:current_username]).to eq "test_user" 
      Thread.current[:current_username] = nil
    end
  end

  describe ".current_username" do
    before(:each) { sign_out }
    after(:each) { Thread.current[:current_username] = nil }
    it "returns Thread.current[:current_username] if set" do
      Thread.current[:current_username] = "test_user"
      expect(User.current_username).to eq "test_user"
    end
    it "returns UNAVAILABLE if unset" do
      expect(User.current_username).to eq "UNAVAILABLE"
    end
  end

  describe ".current_username_object" do
    before(:each) { sign_out }
    after(:each) { Thread.current[:current_username] = nil }
    it "returns Thread.current[:current_username] if set" do
      Thread.current[:current_username] = "test_user"
      expect(User.current_username_object).to eq "test_user"
      Thread.current[:current_username] = nil
    end
    it "returns nil if unset" do
      expect(User.current_username_object).to be_nil
    end
    
  end

  describe "#roles" do
    it "returns an array of roles" do
      expect(valid_user.roles).to respond_to :size
    end
    it "returns matching roles" do
      valid_user.smart_team_user = false
      valid_user.smart_team_admin = true
      expect(valid_user.roles).not_to include :smart_team_user
      expect(valid_user.roles).to include :smart_team_admin
    end
  end

  describe "#permissions" do
    before(:each) { valid_user.web_admin = false }
    context "with no roles" do
      before(:each) { expect(valid_user.roles).to be_empty }
      it "returns an empty array" do
        expect(valid_user.permissions).to be_empty
      end
    end
    context "with roles assigned" do
      before(:each) { valid_user.qc_user = true; valid_user.smart_team_user = true }
      before(:each) { expect(valid_user.roles).not_to be_empty }
      it "returns an array of permissions hashes" do
        expect(valid_user.permissions.size).to eq valid_user.roles.size
        valid_user.permissions.each do |p|
          expect(p[BatchesController]).not_to be_nil
        end
      end
    end
  end

  describe "#permit?(controller, action, record)" do
    context "when no roles permit" do
      before(:each) { valid_user.web_admin = false }
      it "returns false" do
        expect(valid_user.permit?(BoxesController, :index, Box)).to eq false
      end
    end
    context "when at least one role permits" do
      before(:each) { valid_user.web_admin = true }
      it "returns true" do
        expect(valid_user.permit?(BoxesController, :index, Box)).to eq true
      end
    end
  end

end
