FactoryGirl.define do

  #specify a format type as a trait when creating a physical object
  factory :physical_object, class: PhysicalObject do
    # required fields
    # association :unit
    # select an existing unit since we are seeding unit data
    unit_id { Unit.all[rand(Unit.all.size)].id }

    trait :barcoded do
      mdpi_barcode { BarcodeHelper.valid_mdpi_barcode }
    end

    trait :cdr do
      format "CD-R"
      association :technical_metadatum, factory: [:technical_metadatum, :cdr]
    end
    trait :dat do
      format "DAT"
      association :technical_metadatum, factory: [:technical_metadatum, :dat]
    end
    trait :lp do
      format "LP"
      association :technical_metadatum, factory: [:technical_metadatum, :analog_sound_disc]
    end
    trait :open_reel do
      format "Open Reel Audio Tape"
      association :technical_metadatum, factory: [:technical_metadatum, :open_reel]
    end
    trait :betacam do
      format "Betacam"
      association :technical_metadatum, factory: [:technical_metadatum, :betacam]
    end
    trait :eight_mm do
      format "8mm Video"
      association :technical_metadatum, factory: [:technical_metadatum, :eight_mm]
    end
    trait :umatic do
      format "U-matic"
      association :technical_metadatum, factory: [:technical_metadatum, :umatic]
    end
    trait :boxable do
      cdr
    end
    trait :binnable do
      open_reel
    end
    trait :binable do
      binnable
    end

    generation ""
    group_position 1
    association :group_key, factory: :group_key
    #association :digital_provenance, factory: :digital_provenance
    after(:build) do |po|
      po.digital_provenance ||= FactoryGirl.build(:digital_provenance, physical_object: po)
    end
    #at least one must be set of MDPI barcode, IUCAT barcode, title, call number
    title "FactoryGirl object"
    #mdpi_barcode { BarcodeHelper.valid_mdpi_barcode }


  end

  factory :invalid_physical_object, parent: :physical_object do
    title nil
  end

end
