#
# requires let statements for:
# target_object
#
shared_examples "has user field" do 

  describe "#default_values" do
    let(:default_values) { target_object.user = nil; target_object.default_values }
    it "assigns a user value" do
      default_values
      expect(target_object.user).not_to be_nil
    end

    it "gets session[:username] as default username" do
      sign_in("user@example.com")
      default_values
      expect(target_object.user).to eq "user@example.com"
    end

    it "gets UNAVAILABLE as default username if unavailable from session" do
      sign_out
      default_values
      expect(target_object.user).to eq "UNAVAILABLE"
    end
  end

end

