FactoryGirl.define do

  factory :technical_metadatum, class: TechnicalMetadatum do
   # as_technical_metadatum_id
   # as_technical_metadatum_type
   # physical_object_id
   # picklist_specification_id
   trait :cdr do
     as_technical_metadatum_type "CdrTm"
     association :as_technical_metadatum, factory: :cdr_tm
   end
  end

  factory :cdr_tm, class: CdrTm  do
    damage "None"
    breakdown_of_materials 0
    fungus 0
    other_contaminants 0
    format_duration "Unknown"
  end

end
