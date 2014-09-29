require 'rails_helper'

describe PhysicalObject do

  let(:po) { FactoryGirl.create :physical_object, :cdr }
  let(:valid_po) { FactoryGirl.build :physical_object, :cdr }
  let(:invalid_po) { FactoryGirl.build :physical_object, :cdr }
  let(:picklist) { FactoryGirl.create :picklist }
  let(:box) { FactoryGirl.create :box }
  let(:bin) { FactoryGirl.create :bin }

  describe "FactoryGirl" do
    specify "provides a valid object" do
      expect(valid_po).to be_valid
      expect(valid_po.technical_metadatum).to be_valid
      expect(valid_po.technical_metadatum.as_technical_metadatum).to be_valid
    end
    specify "provides an invalid object" do
      expect(invalid_po).to be_valid
    end
  end

  describe "has required attributes:" do
    it "requires a format" do
      expect(valid_po.format).not_to be_blank
      valid_po.format = ""
      expect(valid_po).to be_invalid
    end
  
    it "requires a format from format list" do
      valid_po.format = "invalid format"
      expect(valid_po).to be_invalid
    end
  
    it "requires a unit" do
      expect(valid_po.unit).not_to be_nil
      valid_po.unit = nil
      expect(valid_po).to be_invalid
    end
  
    it "requires a group_position" do
      expect(valid_po.group_position).to be > 0
      valid_po.group_position = nil
      expect(valid_po).to be_invalid
    end
    it "automatically resolves group_position collisions by advancing other object's position" do
      po.save
      dup_po = po.dup
      expect(dup_po.group_position).to eq 1
      dup_po.save
      dup_po.reload
      po.reload
      expect(dup_po.group_position).to eq 1
      expect(po.group_position).to eq 2
    end
    it "automatically extends group_key.group_total" do
      expect(po.group_key.group_total).to eq 1
      po.group_position = 2
      po.save
      po.reload
      expect(po.group_key.group_total).to eq 2
    end

    #technical_metadatum: separate section

    it "requires one of mdpi_barcode, iucat_barcode, title, call_number" do
      valid_po.mdpi_barcode = valid_po.iucat_barcode = valid_po.title = valid_po.call_number = ""
      expect(valid_po).to be_invalid
    end
  end
 
  describe "has optional attributes:" do
    
    it "generates a carrier_stream_index" do
      expect(valid_po.carrier_stream_index).to_not be_blank
    end
  
    it "has no notes by default" do
      expect(valid_po.notes).to be_empty
    end

    it "must have a valid generation value" do
      valid_po.generation = "invalid value"
      expect(valid_po).not_to be_valid
    end
  end

  describe "has relationships" do
    specify "can belong to a box" do
      expect(valid_po.box).to be_nil
    end
    specify "can belong to a bin" do
      expect(valid_po.bin).to be_nil
    end
    specify "can belong to a picklist" do
      expect(valid_po.picklist).to be_nil
    end
    specify "can belong to a container" do
      expect(valid_po.container).to be_nil
    end
    specify "can belong to a spreadsheet" do
      expect(valid_po.spreadsheet).to be_nil
    end
    specify "must belong to a unit" do
      expect(valid_po.unit).not_to be_nil
      valid_po.unit = nil
      expect(valid_po).not_to be_valid
    end
    specify "must belong to a group key" do
      expect(valid_po.group_key).not_to be_nil
    end
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

  describe "mdpi_barcode" do
    it "accepts 0 values" do
      valid_po.mdpi_barcode = 0
      expect(valid_po).to be_valid
    end
    it "accepts valid full unique values" do
      valid_po.mdpi_barcode = valid_mdpi_barcode
      expect(valid_po).to be_valid
    end
    it "rejects valid, duplicate values" do
      valid_po.mdpi_barcode = box.mdpi_barcode
      expect(valid_po).to be_invalid
    end
    it "rejects invalid values" do
      valid_po.mdpi_barcode = invalid_mdpi_barcode
      expect(valid_po).to be_invalid
    end
  end

  describe "technical metadata" do
    it "is generated before validation, if missing" do
      valid_po.technical_metadatum = nil
      valid_po.valid?
      expect(valid_po.technical_metadatum).not_to be_nil
    end
    it "is re-generated before validation, on format change" do
      expect(valid_po).to be_valid
      expect(valid_po.technical_metadatum.as_technical_metadatum_type).not_to eq "DatTm"
      valid_po.format = "DAT"
      valid_po.valid?
      expect(valid_po.technical_metadatum.as_technical_metadatum_type).to eq "DatTm"
    end
    it "is not generated for invalid format" do
      valid_po.technical_metadatum = nil
      valid_po.format = "INVALID FORMAT"
      expect(valid_po).not_to be_valid
      expect(valid_po.technical_metadatum).to be_nil
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
      expect(valid_po.carrier_stream_index).to eq valid_po.group_identifier + "_1_1"
    end
    describe "#container_id" do
      it "returns nil if uncontained" do
        expect(valid_po.container_id).to be_nil
      end
      it "returns box id if boxed" do
        valid_po.box = box
	valid_po.bin = bin
	expect(valid_po.container_id).to eq box.id
      end
      it "returns bin id if binned" do
        valid_po.bin = bin
	expect(valid_po.container_id).to eq bin.id
      end
    end
    it "#file_prefix" do
      expect(valid_po.file_prefix).to eq "MDPI_" + valid_po.mdpi_barcode.to_s
    end
    it "#file_bext" do
      expect(valid_po.unit).not_to be_nil
      expect(valid_po.file_bext).to eq "Indiana University, Bloomington. " +
	valid_po.unit.name + ". " +
	(valid_po.collection_identifier.nil? ? "" : valid_po.collection_identifier + ". ") +
	(valid_po.call_number.nil? ? "" : valid_po.call_number + ". ") +
	"File use: "
    end
    it "#file_icmt" do
      expect(valid_po.file_icmt).to eq valid_po.file_bext
    end
    it "#file_iarl" do
      expect(valid_po.file_iarl).to eq "Indiana University, Bloomington. #{valid_po.unit.name}."
    end
    it "#group_identifier" do
      expect(valid_po.group_identifier).to eq valid_po.group_key.group_identifier
    end
    it "#group_total" do
      valid_po.group_key.group_total = 42
      valid_po.group_key.save
      expect(valid_po.group_total).to eq valid_po.group_key.group_total
    end
  end

  describe "#create_tm" do
    TechnicalMetadatumModule::TM_FORMATS.keys.each do |format|
      context "with valid format: #{format}" do
        let(:tm) { valid_po.create_tm(format) }
        it "creates a new TM" do
          expect(tm).to be_a_new(TechnicalMetadatumModule::TM_FORMAT_CLASSES[format])
        end
      end
    end
    context "with invalid format" do
      let(:tm) { valid_po.create_tm("invalid format") }
      it "raises an error" do
        expect{tm}.to raise_error "Unknown format: invalid format"
      end
    end
  end

  include_examples "ensure_tm examples" do
    let(:test_object) { po }
  end

  describe "#ensure_group_key" do
    it "returns an existing group_key if present" do
      expect(valid_po.ensure_group_key).to equal valid_po.group_key
    end
    it "returns a new, valid group_key if absent" do
      valid_po.group_key = nil
      expect(valid_po.ensure_group_key.id).to be_nil
      expect(valid_po.ensure_group_key).to be_valid
    end
    it "runs before validation" do
      valid_po.group_key = nil
      valid_po.valid?
      expect(valid_po.group_key).not_to be_nil
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

  it_behaves_like "includes Workflow Status Module" do
    let(:object) { valid_po }
    let(:default_status) { "Created" }
    let(:new_status) { "Shipped" }
    let(:valid_status_values) { ["Created", "Verified", "Barcoded", "Boxed", "Binned", "Shipped", "Returned", "Reshelved"] }
    let(:class_title) { "Physical Object" }
  end

end
