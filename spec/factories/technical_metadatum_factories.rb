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
   trait :audiocassette do
     actable_type "AudiocassetteTm"
     association :actable, factory: :audiocassette_tm
   end
   trait :cdr do
     actable_type "CdrTm"
     association :actable, factory: :cdr_tm
   end
   trait :cylinder do
     actable_type "Cylinder"
     association :actable, factory: :cylinder_tm
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
   trait :betamax do
     actable_type "BetamaxTm"
     association :actable, factory: :betamax_tm
   end
   trait :eight_mm do
     actable_type "EightMillimeterVideoTm"
     association :actable, factory: :eight_mm_tm
   end
   trait :film do
     actable_type "FilmTm"
     association :actable, factory: :film_tm
   end
   trait :half_inch_open_reel_video do
     actable_type "HalfInchOpenReelVideoTm"
     association :actable, factory: :half_inch_open_reel_video_tm
   end
   trait :one_inch_open_reel_video do
     actable_type "OneInchOpenReelVideoTm"
     association :actable, factory: :one_inch_open_reel_video_tm
   end
   trait :umatic do
     actable_type "UmaticVideoTm"
     association :actable, factory: :umatic_tm
   end
   trait :vhs do
     actable_type "VhsTm"
     association :actable, factory: :vhs_tm
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

  factory :audiocassette_tm, class: AudiocassetteTm  do
    cassette_type "Compact"
    tape_type "III"
    sound_field "Unknown"
    tape_stock_brand "Brand X"
    noise_reduction "None"
    format_duration "A long time"
    pack_deformation "None"
    damaged_tape 0
    damaged_shell 0
    zero_point46875_ips 0
    zero_point9375_ips 0
    one_point875_ips 0
    three_point75_ips 0
    unknown_playback_speed 1
    fungus 0
    soft_binder_syndrome 0
    other_contaminants 0
  end

  factory :cdr_tm, class: CdrTm  do
    damage "None"
    breakdown_of_materials 0
    fungus 0
    other_contaminants 0
    format_duration ""
  end

  factory :cylinder_tm, class: CylinderTm do
    size "Unknown"
    material "Unknown"
    groove_pitch "Unknown"
    playback_speed "Unknown"
    recording_method "Unknown"
    # structural damage
    fragmented 0
    repaired_break 0
    cracked 0
    damaged_core 0
    # preservation problems
    fungus 0
    efflorescence 0
    other_contaminants 0
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
    dual_mono 0
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

  factory :betamax_tm, class: BetamaxTm do
    format_version 'Unknown'
    recording_standard 'NTSC'
    tape_stock_brand ''
    oxide 'Unknown'
    format_duration 0
    image_format '4:3'
    pack_deformation 'None'
    damaged_tape false
    damaged_shell false
    fungus false
    soft_binder_syndrome false
    other_contaminants false

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

  factory :film_tm, class: FilmTm do
    gauge '8mm'
    frame_rate '16 fps'
    sound 'Sound'
    clean 'No'
    resolution '2k'
    workflow '1'
    on_demand 'No'
    return_on_original_reel 'No'
    mold 'No'
    ad_strip '0.0'
    projection_print false
    a_roll false
    b_roll false
    c_roll false
    d_roll false
    answer_print false
    camera_original false
    composite false
    duplicate false
    edited false
    fine_grain_master false
    intermediate false
    kinescope false
    magnetic_track false
    master false
    mezzanine false
    negative false
    optical_sound_track false
    original false
    outs_and_trims false
    positive false
    reversal false
    work_print false
    separation_master false
    acetate false
    polyester false
    nitrate false
    mixed false
    bw false
    toned false
    tinted false
    hand_coloring false
    stencil_coloring false
    color false
    ektachrome false
    kodachrome false
    technicolor false
    anscochrome false
    eco false
    eastman false
    one_point33 false
    one_point37 false
    one_point66 false
    one_point85 false
    two_point35 false
    two_point39 false
    two_point59 false
    two_point66 false
    anamorphic ''
    optical false
    optical_variable_area false
    optical_variable_density false
    magnetic false
    digital_sdds false
    digital_dts false
    digital_dolby_digital false
    digital_dolby_a false
    digital_dolby_sr false
    sound_on_separate_media false
    poor_wind false
    not_on_core_or_reel false
    lacquer_treated false
    replasticized false
    dusty false
    spoking false
    brittle '0'
    broken '0'
    channeling '0'
    color_fade '0'
    cue_marks '0'
    dirty '0'
    edge_damage '0'
    holes '0'
    peeling '0'
    perforation_damage '0'
    rusty '0'
    scratches '0'
    sound_dual false
    sound_mono false
    sound_multi_track false
    sound_stereo false
    sound_surround false
    soundtrack_damage '0'
    splice_damage '0'
    stains '0'
    sticky '0'
    tape_residue '0'
    tearing '0'
    warp '0'
    water_damage '0'
    return_to 'Return value'
    track_count ''
    format_duration ''
    stock_agfa false
    stock_ansco false
    stock_dupont false
    stock_orwo false
    stock_fuji false
    stock_gevaert false
    stock_kodak false
    stock_ferrania false
    stock_three_m false
    stock_agfa_gevaert false
    stock_pathe false
    stock_unknown false
    conservation_actions ''
    music_track false
    effects_track false
    composite_track false
    dialog false
    outtakes false
    color_space 'Logarithmic 10 bit'

    trait :invalid do
      gauge 'invalid gauge value'
    end
    trait :valid do
    end
  end

  factory :half_inch_open_reel_video_tm, class: HalfInchOpenReelVideoTm do
    format_version 'Unknown'
    recording_standard 'NTSC'
    tape_stock_brand ''
    format_duration 0
    image_format '4:3'
    pack_deformation 'None'
    damaged_tape false
    damaged_reel false
    fungus false
    soft_binder_syndrome false
    other_contaminants false

    trait :invalid do
      pack_deformation "invalid value"
    end
    trait :valid do
    end
  end

  factory :one_inch_open_reel_video_tm, class: OneInchOpenReelVideoTm do
    format_version 'Unknown'
    recording_standard 'NTSC'
    tape_stock_brand ''
    format_duration 0
    image_format '4:3'
    pack_deformation 'None'
    damaged_tape false
    damaged_reel false
    fungus false
    soft_binder_syndrome false
    other_contaminants false

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

  factory :vhs_tm, class: VhsTm do
    format_version 'Unknown'
    recording_standard 'NTSC'
    tape_stock_brand ''
    format_duration 0
    playback_speed 'Unknown'
    size 'Standard'
    image_format '4:3'
    pack_deformation 'None'
    damaged_tape false
    damaged_shell false
    fungus false
    soft_binder_syndrome false
    other_contaminants false

    trait :invalid do
      pack_deformation "invalid value"
    end
    trait :valid do
    end
  end

end
