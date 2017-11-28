FactoryBot.define do

  factory :spreadsheet, class: Spreadsheet do
    filename "FactoryBot_spreadsheet #{Time.now}.csv"
    note "Lorem ipsum"
  end

  factory :invalid_spreadsheet, parent: :spreadsheet do
    filename ""
  end

end
