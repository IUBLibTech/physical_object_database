require 'rails_helper'

describe PhysicalObject do

  let(:po) { FactoryGirl.create :physical_object, :cdr }
  let(:picklist) { FactoryGirl.create :picklist }

  it "requires a format" do
    expect(po.format).not_to be_blank
    po.format = ""
    expect(po).to be_invalid
  end

  it "requires a unit" do
    expect(po.unit).not_to be_nil
    po.unit = nil
    expect(po).to be_invalid
  end

  it "requires a group_position" do
    expect(po.group_position).to be > 0
    po.group_position = nil
    expect(po).to be_invalid
  end

  it "can have a group_key" do
    expect(po.group_key).to be_nil
  end

  it "generates a carrier_stream_index" do
    expect(po.carrier_stream_index).to_not be_blank
  end

  it "has no notes by default" do
    expect(po.notes).to be_empty
  end

  #class methods
  describe "::to_csv" do
    it "lists the picklist, if present" do
      expect(PhysicalObject.to_csv([], picklist)).to eq "Picklist:,FactoryGirl picklist\n"
    end
    it "does not list the picklist, if absent" do
      expect(PhysicalObject.to_csv([], nil)).to eq ""
    end
    it "lists physical objects" do
      po.save
      expect(PhysicalObject.to_csv([po])).to match(/FactoryGirl object/i)
    end
  end

end
