FactoryGirl.define do

  states = []

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
    trait :betamax do
      format "Betamax"
      association :technical_metadatum, factory: [:technical_metadatum, :betamax]
    end
    trait :half_inch_open_reel_video do
      format "1/2-Inch Open Reel Video Tape"
      association :technical_metadatum, factory: [:technical_metadatum, :half_inch_open_reel_video]
    end
    trait :one_inch_open_reel_video do
      format "1-Inch Open Reel Video Tape"
      association :technical_metadatum, factory: [:technical_metadatum, :one_inch_open_reel_video]
    end
    trait :eight_mm do
      format "8mm Video"
      association :technical_metadatum, factory: [:technical_metadatum, :eight_mm]
    end
    trait :umatic do
      format "U-matic"
      association :technical_metadatum, factory: [:technical_metadatum, :umatic]
    end
    trait :vhs do
      format "VHS"
      association :technical_metadatum, factory: [:technical_metadatum, :vhs]
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

    transient do
      final_status nil
    end

    trait :di_status do
      after(:create) do |po|
        unless final_status.nil?
          states.each do |s|
            FactoryGirl.create( :digital_status, physical_object_id: po.id, state: s)
            break if final_status == s
          end
        end
      end
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
    shipment_id nil

  end

  factory :invalid_physical_object, parent: :physical_object do
    title nil
  end

end
