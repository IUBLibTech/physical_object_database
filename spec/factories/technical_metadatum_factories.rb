FactoryGirl.define do

  factory :technical_metadatum, class: TechnicalMetadatum do
   # actable_id
   # actable_type
   # physical_object_id
   # picklist_specification_id
   trait :analog_sound_disc do
     actable_type "AnalogSoundDiscTm"
     association :actable, factory: :analog_sound_disc_tm
   end
   trait :cdr do
     actable_type "CdrTm"
     association :actable, factory: :cdr_tm
   end
   trait :dat do
     actable_type "DatTm"
     association :actable, factory: :dat_tm
   end
   trait :open_reel do
     actable_type "OpenReelTm"
     association :actable, factory: :open_reel_tm
   end
   trait :betacam do
     actable_type "BetacamTm"
     association :actable, factory: :betacam_tm
   end
   trait :eight_mm do
     actable_type "EightMillimeterVideoTm"
     association :actable, factory: :eight_mm_tm
   end
   trait :umatic do
     actable_type "UmaticVideoTm"
     association :actable, factory: :umatic_tm
   end
  end

  factory :analog_sound_disc_tm, class: AnalogSoundDiscTm do
    diameter "12"
    speed "33.3"
    groove_size "Micro"
    groove_orientation "Lateral"
    recording_method "Pressed"
    material "Plastic"
    substrate "N/A"
    coating "N/A"
    equalization ""
    country_of_origin ""
    label ""
    sound_field "Mono"
    subtype "LP"

    delamination 0
    exudation 0
    oxidation 0
    cracked 0
    warped 0
    dirty 0
    scratched 0
    worn 0
    broken 0
    fungus 0
  end

  factory :cdr_tm, class: CdrTm  do
    damage "None"
    breakdown_of_materials 0
    fungus 0
    other_contaminants 0
    format_duration ""
  end

  factory :dat_tm, class: DatTm do
    format_duration ""
    tape_stock_brand ""
    fungus 0
    soft_binder_syndrome 0
    other_contaminants 0
    sample_rate_32k 0
    sample_rate_44_1_k 0
    sample_rate_48k 0
    sample_rate_96k 0
  end

  factory :open_reel_tm, class: OpenReelTm do
    pack_deformation "None"
    reel_size ""
    tape_stock_brand ""
    vinegar_syndrome 0
    fungus 0
    soft_binder_syndrome 0
    other_contaminants 0
    zero_point9375_ips 0
    one_point875_ips 0
    three_point75_ips 0
    seven_point5_ips 0
    fifteen_ips 0
    thirty_ips 0
    full_track 0
    half_track 0
    quarter_track 0
    unknown_track 0
    zero_point5_mils 0
    one_mils 0
    one_point5_mils 0
    mono 0
    stereo 0
    unknown_sound_field 0
    acetate_base 0
    polyester_base 0
    pvc_base 0
    paper_base 0
    unknown_playback_speed 0
  end

  factory :betacam_tm, class: BetacamTm do
    pack_deformation "None"
    fungus false
    soft_binder_syndrome false
    other_contaminants false
    cassette_size ""
    recording_standard ""
    format_duration ""
    tape_stock_brand ""
    image_format ""
    format_version ""

    trait :invalid do
      pack_deformation "invalid value"
    end
    trait :valid do
    end
  end

  factory :eight_mm_tm, class: EightMillimeterVideoTm do
    pack_deformation "None"
    fungus false
    soft_binder_syndrome false
    other_contaminants false
    recording_standard "Unknown"
    format_duration ""
    tape_stock_brand ""
    image_format "Unknown"
    format_version "Unknown"
    playback_speed "Unknown"
    binder_system "Unknown"

    trait :invalid do
      pack_deformation "invalid value"
    end
    trait :valid do
    end
  end

  factory :umatic_tm, class: UmaticVideoTm do
    pack_deformation "None"
    fungus false
    soft_binder_syndrome false
    other_contaminants false
    recording_standard "Unknown"
    format_duration "Unknown"
    size "Small"
    tape_stock_brand ""
    image_format "Unknown"
    format_version "Unknown"

    trait :invalid do
      pack_deformation "invalid value"
    end
    trait :valid do
    end
  end

end
