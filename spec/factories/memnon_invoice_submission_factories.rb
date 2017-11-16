FactoryBot.define do

  factory :memnon_invoice_submission, class: MemnonInvoiceSubmission do
    filename "factory_girl.xlsx"
    submission_date Time.now
    successful_validation false
    validation_completion_percent 0
    bad_headers false
    other_error ""
    problems_by_row nil
  end

end
