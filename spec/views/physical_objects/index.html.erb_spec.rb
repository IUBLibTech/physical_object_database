require "rails_helper"

describe "physical_objects/index" do

  let(:unit) { FactoryGirl.create :unit }
  let(:po_cdr) { FactoryGirl.create :physical_object, :cdr, unit: unit }
  let(:po_dat) { FactoryGirl.create :physical_object, :dat, unit: unit }

  it "lists physical objects" do
    @physical_objects = [po_cdr, po_dat]

    render

    expect(rendered).to match /CD-R/
    expect(rendered).to match /DAT/
    expect(rendered).not_to match /Open Reel/
  end

  it "lists standard action links in each object row" do
    skip "TODO: find way to loop through table rows"
  end

end
