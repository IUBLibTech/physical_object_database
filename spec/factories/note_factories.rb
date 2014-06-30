FactoryGirl.define do

  factory :note, class: Note do
    association :physical_object, :cdr
    body "Lorem ipsum"
    user "test_user"
  end

end
