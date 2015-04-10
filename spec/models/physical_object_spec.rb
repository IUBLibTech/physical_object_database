require 'rails_helper'

describe PhysicalObject do

  let(:po) { FactoryGirl.create :physical_object, :cdr }
  let(:valid_po) { FactoryGirl.build :physical_object, :cdr }
  let(:invalid_po) { FactoryGirl.build :physical_object, :cdr }
  let(:picklist) { FactoryGirl.create :picklist }
  let(:box) { FactoryGirl.create :box }
  let(:bin) { FactoryGirl.create :bin }

  describe "FactoryGirl" do
    [:cdr, :dat, :lp, :open_reel].each do |tm_type|
      context "with tm_type: #{tm_type}" do
        let(:valid_po) { FactoryGirl.build :physical_object, tm_type }
        specify "provides a valid object" do
	  expect(valid_po).to be_valid
          expect(valid_po.technical_metadatum).to be_valid
          expect(valid_po.technical_metadatum.as_technical_metadatum).to be_valid
	end
      end
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

  describe "has relationships:" do
    specify "can belong to a box" do
      expect(valid_po.box).to be_nil
    end
    specify "can belong to a bin" do
      expect(valid_po.bin).to be_nil
    end
    PhysicalObject.const_get(:BOX_FORMATS).each_with_index do |format, index|
      describe "boxable format: #{format}" do
        before(:each) { valid_po.format = format }
        specify "cannot belong to a bin and box" do
          valid_po.box = box
          valid_po.bin = bin
          expect(valid_po).not_to be_valid
        end
        specify "can belong to a box" do
          valid_po.box = box
          expect(valid_po).to be_valid
        end
        unless format.in? PhysicalObject.const_get(:BIN_FORMATS)
          specify "cannot belong to a bin" do
            valid_po.bin = bin
            expect(valid_po).not_to be_valid
          end
        end
        if PhysicalObject.const_get(:BOX_FORMATS).size > 1
          specify "cannot belong to a box containing other formats" do
            po.format = PhysicalObject.const_get(:BOX_FORMATS)[index - 1]
            po.box = box
            po.save!
            valid_po.box = box
            expect(valid_po).not_to be_valid
          end
        end
      end
    end
    PhysicalObject.const_get(:BIN_FORMATS).each do |format|
      describe "binnable format: #{format}" do
        before(:each) { valid_po.format = format }
        specify "cannot belong to a bin and box" do
          valid_po.box = box
          valid_po.bin = bin
          expect(valid_po).not_to be_valid
        end
        specify "can belong to a bin" do
          valid_po.format = format
          valid_po.bin = bin
          expect(valid_po).to be_valid
        end
        unless format.in? PhysicalObject.const_get(:BOX_FORMATS)
          specify "cannot belong to a box" do
            valid_po.format = format
            valid_po.box = box
            expect(valid_po).not_to be_valid
          end
        end
        if PhysicalObject.const_get(:BIN_FORMATS).size > 1
          specify "cannot belong to a bin containing other formats" do
            po.format = PhysicalObject.const_get(:BIN_FORMATS)[index - 1]
            po.bin = bin
            po.save!
            valid_po.bin = bin
            expect(valid_po).not_to be_valid
          end
        end
        specify "cannnot belong to a bin containing boxes" do
          box.bin = bin
          box.save
          valid_po.bin = bin
          expect(valid_po).not_to be_valid
        end
      end
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
    specify "can have workflow statuses" do
      expect(valid_po.workflow_statuses.size).to be >= 0
    end
    specify "can have condition statuses" do
      expect(valid_po.condition_statuses.size).to be >= 0
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

  describe "#inferred_workflow_status" do
    it "returns Binned if binned" do
      valid_po.bin = bin
      expect(valid_po.inferred_workflow_status).to eq "Binned"
    end
    it "returns Boxed if boxed" do
      valid_po.box = box
      expect(valid_po.inferred_workflow_status).to eq "Boxed"
    end
    it "returns On Pick List if on pick list" do
      valid_po.picklist = picklist
      expect(valid_po.inferred_workflow_status).to eq "On Pick List"
    end
    it "returns On Pick List if barcoded, AND on pick list" do
      valid_po.mdpi_barcode = valid_mdpi_barcode
      valid_po.picklist = picklist
      expect(valid_po.inferred_workflow_status).to eq "On Pick List"
    end
    it "returns Unassigned if unassigned, and barcoded" do
      valid_po.mdpi_barcode = valid_mdpi_barcode
      expect(valid_po.inferred_workflow_status).to eq "Unassigned"
    end
    it "returns Unassigned if unassigned, and not barcoded" do
      valid_po.mdpi_barcode = "0"
      expect(valid_po.inferred_workflow_status).to eq "Unassigned"
    end
    ["Unpacked", "Returned to Unit"].each do |set_status|
      it "returns #{set_status} if already in that status" do
        valid_po.current_workflow_status = set_status
        expect(valid_po.inferred_workflow_status).to eq set_status
      end
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
  describe "::per_page" do
    it "should be 50" do
      expect(PhysicalObject.per_page).to eq 50
    end
  end
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
    describe "#display_workflow_status" do
      # set precursors to Binned/Boxed status
      before(:each) do
        valid_po.mdpi_barcode = valid_mdpi_barcode
        valid_po.picklist = picklist
      end
      it "displays physical object workflow status" do
        expect(valid_po.display_workflow_status).to match /^#{valid_po.current_workflow_status}/
      end
      specify "when Binned, also display bin status (if not Created)" do
        bin.current_workflow_status = "Sealed"
        valid_po.bin = bin
        valid_po.assign_inferred_workflow_status
        expect(valid_po.current_workflow_status).to eq "Binned"
        expect(valid_po.display_workflow_status).to match />>/
        expect(valid_po.display_workflow_status).to match /#{valid_po.bin.display_workflow_status}$/
      end
      specify "when Boxed (into a bin), also displays bin status (if not Created)" do
        bin.current_workflow_status = "Sealed"
        box.bin = bin
        valid_po.box = box
        valid_po.assign_inferred_workflow_status
        expect(valid_po.current_workflow_status).to eq "Boxed"
        expect(valid_po.display_workflow_status).to match />>/
        expect(valid_po.display_workflow_status).to match /#{valid_po.box.bin.display_workflow_status}$/
      end
      specify "when Binned, also display bin status (if not Created)" do
        bin.current_workflow_status = "Created"
        valid_po.bin = bin
        valid_po.assign_inferred_workflow_status
        expect(valid_po.current_workflow_status).to eq "Binned"
        expect(valid_po.display_workflow_status).not_to match /#{valid_po.bin.display_workflow_status}$/
      end
      specify "when Boxed (into a bin), supresses Bin status if Created" do
        bin.current_workflow_status = "Created"
        box.bin = bin
        valid_po.box = box
        valid_po.assign_inferred_workflow_status
        expect(valid_po.current_workflow_status).to eq "Boxed"
        expect(valid_po.display_workflow_status).not_to match /#{valid_po.box.bin.display_workflow_status}$/
      end
      specify "when Boxed (but not yet binned), only displays physical object status" do
        bin.current_workflow_status = "Created"
        valid_po.box = box
        valid_po.assign_inferred_workflow_status
        expect(valid_po.current_workflow_status).to eq "Boxed"
        expect(valid_po.display_workflow_status).to eq "Boxed"
      end
      specify "when Boxed, but no box assigned, adds warning to output" do
        valid_po.current_workflow_status = "Boxed"
        expect(valid_po.display_workflow_status).to match /No bin or box assigned/
      end
      specify "when Binned, but no bin assigned, adds warning to output" do
        valid_po.current_workflow_status = "Binned"
        expect(valid_po.display_workflow_status).to match /No bin or box assigned/
      end
    end
    describe "#condition_notes" do
      condition_user = "condition_user"
      let(:cst_templates) { ConditionStatusTemplate.where(object_type: "Physical Object") }
      let!(:active1) { FactoryGirl.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Active 1", active: true, condition_status_template_id: cst_templates[0].id }
      let!(:active2) { FactoryGirl.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Active 2", active: true, condition_status_template_id: cst_templates[1].id }
      let!(:inactive1) { FactoryGirl.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Inactive 1", active: false, condition_status_template_id: cst_templates[2].id }
      let!(:inactive2) { FactoryGirl.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Inactive 2", active: false, condition_status_template_id: cst_templates[3].id }
      [false, true].each do |include_metadata|
        context "include_metadata: #{include_metadata}" do
          let!(:export_results) { po.reload; po.condition_notes(include_metadata) }
          it "exports active notes text, only" do
            expect(export_results).to match active1.notes
            expect(export_results).to match active2.notes
            expect(export_results).not_to match inactive1.notes
            expect(export_results).not_to match inactive2.notes
          end
          it "exports active template names, only" do
            expect(export_results).to match active1.condition_status_template.name.upcase
            expect(export_results).to match active2.condition_status_template.name.upcase
            expect(export_results).not_to match inactive1.condition_status_template.name.upcase
            expect(export_results).not_to match inactive2.condition_status_template.name.upcase
          end
          if include_metadata
            specify "includes condition metadata" do
              expect(export_results).to match /\[#{condition_user}, /
            end
          else
            specify "does not includes condition metadata" do
              expect(export_results).not_to match /\[#{condition_user}, /
            end
          end
        end
      end
    end
    describe "#other_notes" do
      note_user = "note_user"
      let!(:external1) { FactoryGirl.create :note, physical_object: po, export: true, body: "External 1", user: note_user }
      let!(:external2) { FactoryGirl.create :note, physical_object: po, export: true, body: "External 2", user: note_user }
      let!(:internal1) { FactoryGirl.create :note, physical_object: po, export: false, body: "Internal 1", user: note_user }
      let!(:internal2) { FactoryGirl.create :note, physical_object: po, export: false, body: "Internal 2", user: note_user }
      [ { export_flag: false, include_metadata: false },
        { export_flag: false, include_metadata: true },
        { export_flag: true, include_metadata: false },
        { export_flag: false, include_metadata: true } ].each do |params_hash|
        context "export_flag: #{params_hash[:export_flag].to_s}, include_metadata: #{params_hash[:include_metadata].to_s}" do
          let!(:export_results) { po.other_notes(params_hash[:export_flag], params_hash[:include_metadata]) }
          if params_hash[:export_flag]
            specify "includes external note body text, only" do
              expect(export_results).to match external1.body
              expect(export_results).to match external2.body
              expect(export_results).not_to match internal1.body
              expect(export_results).not_to match internal2.body
            end
          else
            specify "includes internal note body text, only" do
              expect(export_results).not_to match external1.body
              expect(export_results).not_to match external2.body
              expect(export_results).to match internal1.body
              expect(export_results).to match internal2.body
            end
          end
          if params_hash[:include_metadata]
            specify "includes note metadata" do
              expect(export_results).to match /\[#{note_user}, /
            end
          else
            specify "excludes note metadata" do
              expect(export_results).not_to match /\[#{note_user}, /
            end
          end
        end
      end
    end
    describe "#master_copies" do
      context "with technical metadatum present" do
        it "returns values from technical metadatum" do
	  expect(po.master_copies).to eq po.technical_metadatum.as_technical_metadatum.master_copies
	end
      end
      context "without technical metadatum present" do
        before(:each) { po.technical_metadatum = nil }
        it "returns 0" do
	  expect(po.master_copies).to eq 0
	end
      end
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

  it_behaves_like "includes ConditionStatusModule:" do
    let(:condition_status) { FactoryGirl.create(:condition_status, :physical_object, physical_object: po) }
    let(:target_object) { po }
    let(:class_title) { "Physical Object" }
  end

  status_list = ["Unassigned", "On Pick List", "Boxed", "Binned", "Unpacked", "Returned to Unit"] 
  # pass status_list arg here to test previous/next methods
  it_behaves_like "includes Workflow Status Module" do
    let(:object) { valid_po }
    let(:default_status) { "Unassigned" }
    let(:new_status) { "On Pick List" }
    let(:valid_status_values) { status_list }
    let(:class_title) { "Physical Object" }
  end

end
