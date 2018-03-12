describe PhysicalObjectPolicy do
  let(:policy) { PhysicalObjectPolicy.new(user, physical_object) }
  let(:physical_object) { FactoryBot.create :physical_object, :cdr }
  WEB_ADMIN = User.where(username: "web_admin").first

  context "web_admin user" do
    let(:user) { WEB_ADMIN }

    specify { expect(policy).to authorize(:index) }

    specify { expect(policy).to authorize(:new) }
  end

  pending "test other roles, policies"

end
