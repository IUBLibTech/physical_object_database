FactoryBot.define do

  factory :pod_report, class: PodReport do
    status 'Running'
    filename 'report.xls'

    trait :invalid do
      filename nil
    end
  end

  factory :invalid_pod_report, parent: :pod_report do
    mdpi_barcode nil
  end
end
