FactoryGirl.define do

  factory :group_key, class: GroupKey do
    group_total 1
  end

  factory :invalid_group_key, parent: :group_key do
    group_total -1
  end

end
