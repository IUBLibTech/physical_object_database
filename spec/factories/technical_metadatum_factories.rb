FactoryGirl.define do

  factory :technical_metadatum, class: TechnicalMetadatum do
   # as_technical_metadatum_id
   # as_technical_metadatum_type
   # physical_object_id
   # picklist_specification_id
   trait :analog_sound_disc do
     as_technical_metadatum_type "AnalogSoundDiscTm"
     association :as_technical_metadatum, factory: :analog_sound_disc_tm
   end
   trait :cdr do
     as_technical_metadatum_type "CdrTm"
     association :as_technical_metadatum, factory: :cdr_tm
   end
   trait :dat do
     as_technical_metadatum_type "DatTm"
     association :as_technical_metadatum, factory: :dat_tm
   end
   trait :open_reel do
     as_technical_metadatum_type "OpenReelTm"
     association :as_technical_metadatum, factory: :open_reel_tm
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
    equalization "RIAA"
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
    format_duration "Unknown"
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
    one_direction 0
    two_directions 0
    unknown_direction 0
  end

end
