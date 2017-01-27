FactoryGirl.define do
  factory :digital_file_provenance, class: DigitalFileProvenance do
    association :digital_provenance, factory: :digital_provenance
    created_by "FactoryGirl User"
    filename "temporary filename" #replaced in after(:build) call
    date_digitized Time.now
    #association :signal_chain #nil

    tape_fluxivity 1
    volume_units 0
    analog_output_voltage 0
    peak -1
    rumble_filter 1
    reference_tone_frequency 1

    after(:build) do |dfp|
      dfp.filename = dfp.digital_provenance.physical_object.generate_filename unless dfp.filename.nil?
    end

    trait :invalid do
      filename nil
    end
  end
end
