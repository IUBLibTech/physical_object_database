describe PhysicalObjectPolicy do
  subject { PhysicalObjectPolicy.new(user, physical_object) }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }

  context "admin user" do
    let(:user) { User.first.username }

    specify { expect(subject).to authorize(:index) }

    specify { expect(subject).to authorize(:new) }
  end

end
