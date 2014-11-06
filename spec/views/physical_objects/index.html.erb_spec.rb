require "rails_helper"

describe "physical_objects/index" do

  let(:po_cdr) { FactoryGirl.create :physical_object, :cdr }
  let(:po_dat) { FactoryGirl.create :physical_object, :dat }

  it "lists physical objects" do
    @physical_objects = [po_cdr, po_dat]

    render

    expect(rendered).to match /CD-R/
    expect(rendered).to match /DAT/
    expect(rendered).not_to match /Open Reel/
  end


end
