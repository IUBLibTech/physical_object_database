describe PhysicalObjectPolicy do
  subject { PhysicalObjectPolicy.new(user, physical_object) }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }
  WEB_ADMIN = User.find_by(username: "web_admin")

  context "web_admin user" do
    let(:user) { WEB_ADMIN }

    specify { expect(subject).to authorize(:index) }

    specify { expect(subject).to authorize(:new) }
  end

  pending "test other roles, policies"

end
