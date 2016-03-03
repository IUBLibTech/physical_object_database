describe SessionsHelper do
  #sign_in
  #current_username
  #current_username=(username)
  #current_username?(username)
  #current_user
  #signed_in_user
  describe "#signed_in?" do
    it "returns false until user has signed in" do
      expect(helper.signed_in?).not_to be
    end
  end
  #sign_out
  #store_location
  #redirect_back_or_to(default=root_url)
end
