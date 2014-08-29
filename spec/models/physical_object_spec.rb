require 'rails_helper'

describe PhysicalObject do

  let(:po) { FactoryGirl.create :physical_object, :cdr }
  let(:valid_po) { FactoryGirl.build :physical_object, :cdr }
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

  describe "#generation_values" do
    let(:values) { valid_po.generation_values }
    it "maps values to themselves " do
      values.each do |key, value|
        expect(key).to eq value
      end
    end
    it "includes: (blank), Original, Copy, Unknown" do
      expect(values.keys.sort).to eq ["", "Original", "Copy", "Unknown"].sort
    end
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

  describe "provides virtual attributes:" do
    it "#carrier_stream_index" do
      skip "TODO"
    end
    it "#file_prefix" do
      expect(valid_po.file_prefix).to eq "MDPI_" + valid_po.mdpi_barcode.to_s
    end
    it "#file_bext" do
      expect(valid_po.file_bext).to eq "Indiana University Bloomington. " +
	valid_po.unit.name + ". " +
	(valid_po.collection_identifier.nil? ? "" : valid_po.collection_identifier + ". ") +
	(valid_po.call_number.nil? ? "" : valid_po.call_number + ". ") +
	"File use: "
    end
    it "#file_icmt" do
      expect(valid_po.file_icmt).to eq valid_po.file_bext
    end
    it "#file_iarl" do
      expect(valid_po.file_iarl).to eq "Indiana University Bloomington. #{valid_po.unit.name}."
    end
  end

  describe "includes ConditionStatusModule:" do
    let(:condition_status) { FactoryGirl.create(:condition_status, physical_object: po) }
    it "#class_title returns 'Physical Object'" do
      expect(valid_po.class_title).to eq "Physical Object"
    end
    it "#condition_status_options returns status options" do
      condition_status
      expect(po.condition_status_options.first.first).to eq condition_status.name
      expect(po.condition_status_options.size).to eq 1
    end
    it "#has_condition(object, status_name) returns true/false for object, status_name" do
      expect(ConditionStatusModule.has_condition?(po, condition_status.name)).to be true
      expect(ConditionStatusModule.has_condition?(po, "foo")).to be false
    end
  end

  describe "includes WorkflowStatusModule:" do
    it "does WorkflowStatusModule things..." do
      skip "TODO"
    end
  end

end
