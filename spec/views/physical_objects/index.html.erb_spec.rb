require "rails_helper"

describe "physical_objects/index" do

  let(:unit) { FactoryGirl.create :unit }
  let(:po_cdr) { FactoryGirl.create :physical_object, :cdr, unit: unit }
  let(:po_dat) { FactoryGirl.create :physical_object, :dat, unit: unit }

  it "lists physical objects" do
    po_dat.current_workflow_status = "Binned"
    po_cdr.current_workflow_status = "Barcoded"

    puts "What is status [#{po_cdr.current_workflow_status}]"

    @physical_objects = [po_cdr, po_dat]

    render

    #expect(rendered).to match /CD-R/
    #expect(rendered).to match /DAT/
    #expect(rendered).not_to match /Open Reel/
  end

end
