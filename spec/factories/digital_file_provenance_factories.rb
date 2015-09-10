FactoryGirl.define do
  factory :digital_file_provenance, class: DigitalFileProvenance do
    created_by "FactoryGirl User"
    date_digitized Time.now
    filename "FactoryGirl filename"

    trait :invalid do
      filename nil
    end
  end
end
