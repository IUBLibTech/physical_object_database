describe PhysicalObject do
  include TechnicalMetadatumModule

  let(:po) { FactoryBot.create :physical_object, :cdr }
  let(:barcoded_po) { FactoryBot.create :physical_object, :cdr, :barcoded }
  let(:grouped_po) { FactoryBot.build :physical_object, :cdr, group_key: po.group_key }
  let(:video_po) { FactoryBot.build :physical_object, :umatic }
  let(:film_po) { FactoryBot.build :physical_object, :film }
  let(:boxable_po) { FactoryBot.build :physical_object, :boxable, :barcoded }
  let(:binnable_po) { FactoryBot.build :physical_object, :binnable, :barcoded }
  let(:valid_po) { FactoryBot.build :physical_object, :cdr, unit: Unit.where(campus: 'Bloomington').first }
  let(:invalid_po) { FactoryBot.build :physical_object, :cdr }
  let(:picklist) { FactoryBot.create :picklist }
  let(:box) { FactoryBot.create :box }
  let(:bin) { FactoryBot.create :bin }
  let(:batch) { FactoryBot.create :batch }

  tm_types = [:cdr, :dat, :lp, :open_reel, :betacam, :betamax, :eight_mm, :half_inch_open_reel_video, :one_inch_open_reel_video, :umatic, :vhs, :film]
  tm_factories = {
    'CD-R' => :cdr_tm,
    'Cylinder' => :cylinder_tm,
    'DAT' => :dat_tm,
    'DVD' => :dvd_tm,
    'LP' => :analog_sound_disc_tm,
    'Aluminum Disc' => :analog_sound_disc_tm,
    'Lacquer Disc' => :analog_sound_disc_tm,
    '45' => :analog_sound_disc_tm,
    '78' => :analog_sound_disc_tm,
    'Other Analog Sound Disc' => :analog_sound_disc_tm,
    'Open Reel Audio Tape' => :open_reel_tm,
    'Betacam' => :betacam_tm,
    'Betamax' => :betamax_tm,
    '8mm Video' => :eight_mm_tm,
    '1/2-Inch Open Reel Video Tape' => :half_inch_open_reel_video_tm,
    '1-Inch Open Reel Video Tape' => :one_inch_open_reel_video_tm,
    'U-matic' => :umatic_tm,
    'VHS' => :vhs_tm,
    'Audiocassette' => :audiocassette_tm,
    'Film' => :film_tm
  }

  describe "FactoryBot" do
    tm_types.each do |tm_type|
      context "with tm_type: #{tm_type}" do
        let(:valid_po) { FactoryBot.build :physical_object, tm_type }
        specify "provides a valid object" do
          expect(valid_po).to be_valid
          expect(valid_po.technical_metadatum).to be_valid
          expect(valid_po.technical_metadatum.specific).to be_valid
        end
      end
    end
    specify "provides an invalid object" do
      expect(invalid_po).to be_valid
    end
  end

describe "sets proper media type" do
    tm_types.each do |tm_type|
    context "with tm_type: #{tm_type}" do
      let(:po) { FactoryBot.create :physical_object, tm_type }
      specify "saves proper media type" do
        expect(po.audio).to eq (TechnicalMetadatumModule.tm_genres[po.format] == :audio ? true : nil)
        expect(po.video).to eq (TechnicalMetadatumModule.tm_genres[po.format] == :video ? true : nil)
      end
    end
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
    expect(grouped_po.group_position).to eq 1
    grouped_po.save!
    grouped_po.reload
    po.reload
    expect(grouped_po.group_position).to eq 1
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

    specify "has_ephemera" do
      expect(valid_po).to respond_to :has_ephemera?
    end

    describe "ephemera_returned" do
      specify "is optional" do
        expect(valid_po).to respond_to :ephemera_returned?
      end
      specify "can only be true of has_ephemera is true" do
        valid_po.has_ephemera = false
        valid_po.ephemera_returned = true
        valid_po.valid?
        expect(valid_po).not_to be_valid
      end
    end
  end

  describe "has relationships:" do
    describe "box" do
      specify "can belong to a box" do
        expect(valid_po).to respond_to :box_id
      end
      #FIXME: need to properly create TM objects via factories
      TechnicalMetadatumModule.box_formats.each_with_index do |format, index|
        describe "boxable format: #{format}" do
          before(:each) do
            valid_po.format = format
            valid_po.ensure_tm.assign_attributes(FactoryBot.attributes_for tm_factories[format])
          end
          specify "cannot belong to a bin and box" do
            valid_po.box = box
            valid_po.bin = bin
            expect(valid_po).not_to be_valid
          end
          specify "can belong to a box if a barcode is set" do
	    valid_po.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
            valid_po.box = box
            expect(valid_po).to be_valid
          end
          specify "cannot belong to a box if a barcode is not set" do
            valid_po.box = box
            expect(valid_po).not_to be_valid
          end
          unless format.in? TechnicalMetadatumModule.bin_formats
            specify "cannot belong to a bin" do
              valid_po.bin = bin
              expect(valid_po).not_to be_valid
            end
          end
          if TechnicalMetadatumModule.box_formats.size > 1
            specify "cannot belong to a box containing other formats" do
              format_value = TechnicalMetadatumModule.box_formats[index - 1]
              po.format = format_value
              po.ensure_tm.assign_attributes(FactoryBot.attributes_for tm_factories[format_value])
	            po.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
              po.box = box
              po.save!
              valid_po.box = box
              expect(valid_po).not_to be_valid
            end
          end
        end
      end
    end
    describe "bin" do
      specify "can belong to a bin" do
        expect(valid_po).to respond_to :bin_id
      end
      TechnicalMetadatumModule.bin_formats.each_with_index do |format, index|
        describe "binnable format: #{format}" do
          before(:each) do
            valid_po.format = format
            valid_po.ensure_tm.assign_attributes(FactoryBot.attributes_for tm_factories[format])
          end
          specify "cannot belong to a bin and box" do
            valid_po.box = box
            valid_po.bin = bin
            expect(valid_po).not_to be_valid
          end
          specify "can belong to a bin if barcode is set" do
	    valid_po.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
            valid_po.bin = bin
            expect(valid_po).to be_valid
          end
          specify "cannot belong to a bin if barcode is not set" do
            valid_po.bin = bin
            expect(valid_po).not_to be_valid
          end
          unless format.in? TechnicalMetadatumModule.box_formats
            specify "cannot belong to a box" do
              valid_po.format = format
              valid_po.box = box
              expect(valid_po).not_to be_valid
            end
          end
          if TechnicalMetadatumModule.bin_formats.size > 1
            specify "cannot belong to a bin containing other formats" do
              format_value = TechnicalMetadatumModule.bin_formats[index - 1]
              po.format = format_value
              po.ensure_tm.assign_attributes(FactoryBot.attributes_for tm_factories[format_value])
	            po.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
              po.bin = bin
              po.save!
              valid_po.bin = bin
              expect(valid_po).not_to be_valid
            end
          end
          specify "cannnot belong to a bin containing boxes" do
            box.bin = bin
            box.save
	    valid_po.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
            valid_po.bin = bin
            expect(valid_po).not_to be_valid
          end
        end
      end
    end
    describe "through relationships" do
      describe "box_bin" do
        specify "returns po.box.bin" do
          boxable_po.box = box; boxable_po.save!
          box.bin = bin; box.save!
          expect(boxable_po.box_bin).to eq bin
        end
      end
      describe "bin_batch" do
        specify "returns po.bin.batch" do
          binnable_po.bin = bin; binnable_po.save!
          bin.batch = batch; bin.save!
          expect(binnable_po.bin_batch).to eq batch
        end
      end
      describe "box_batch" do
        specify "returns po.box.bin.batch" do
          boxable_po.box = box; boxable_po.save!
          box.bin = bin; box.save!
          bin.batch = batch; bin.save!
          expect(boxable_po.box_batch).to eq batch
        end
      end
    end
    describe "picklist" do
      specify "can belong to a picklist" do
        expect(valid_po).to respond_to :picklist_id
        expect(valid_po.picklist).to be_nil
      end
    end
    describe "shipment" do
      specify "can belong to a shipment" do
        expect(valid_po).to respond_to :shipment_id
        expect(valid_po.shipment).to be_nil
      end
    end
    describe "spreadsheet" do
      specify "can belong to a spreadsheet" do
        expect(valid_po).to respond_to :spreadsheet_id
        expect(valid_po.spreadsheet).to be_nil
      end
    end
    describe "unit" do
      specify "belongs to" do
        expect(valid_po).to respond_to :unit_id
      end
      specify "must belong to a unit" do
        valid_po.unit = nil
        expect(valid_po).not_to be_valid
      end
    end
    describe "group key" do
      specify "belongs to" do
        expect(valid_po).to respond_to :group_key_id
      end
      specify "must belong to a group key" do
        expect(valid_po.group_key).not_to be_nil
      end
    end
    describe "workflow_statuses" do
      specify "can have workflow statuses" do
        expect(valid_po.workflow_statuses.size).to be >= 0
      end
    end
    describe "condition statuses" do
      specify "can have condition statuses" do
        expect(valid_po.condition_statuses.size).to be >= 0
      end
    end
    describe "digital provenance" do
      specify "has_one" do
        expect(valid_po).to respond_to :digital_provenance
        expect(valid_po).not_to respond_to :digital_provenance_id
      end
      specify "is required" do
        valid_po.digital_provenance = nil
	expect(valid_po).not_to be_valid
      end
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

  describe "Digital workflow fields" do
    describe "#digital_workflow_status" do
      it 'returns a string' do
        expect(valid_po.digital_workflow_status).to be_a String
      end
    end
    describe "#digital_workflow_category" do
      it 'returns a string' do
        expect(valid_po.digital_workflow_category).to be_a String
      end
      it 'accepts String versions of the acceptable enum integers' do
        expect { valid_po.digital_workflow_category = '0' }.not_to raise_error
      end
      it 'rejcts String versions of the unacceptable enum integers' do
        expect { valid_po.digital_workflow_category = '9' }.to raise_error ArgumentError
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

  describe "#set_container_format" do
    context "in a box" do
      before(:each) { boxable_po.box = box }
      let(:contained) { boxable_po }
      let(:container) { box }
      include_examples "nil and blank format cases"
    end
    context "in a bin" do
      before(:each) { binnable_po.bin = bin }
      let(:contained) { binnable_po }
      let(:container) { bin }
      include_examples "nil and blank format cases"
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
      expect(valid_po.technical_metadatum.actable_type).not_to eq "DatTm"
      valid_po.format = "DAT"
      valid_po.valid?
      expect(valid_po.technical_metadatum.actable_type).to eq "DatTm"
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
      expect(PhysicalObject.to_csv([], picklist)).to eq "Picklist:,FactoryBot picklist\n"
    end
    it "does not list the picklist, if absent" do
      expect(PhysicalObject.to_csv([], nil)).to eq ""
    end
    it "lists physical objects" do
      po.save
      expect(PhysicalObject.to_csv([po])).to match(/FactoryBot object/i)
    end
  end

  #class constants
  describe "EPHEMERA_RETURNED_STATUSES" do
    it "should include Unpacked, Returned to Unit" do
      expect(PhysicalObject::EPHEMERA_RETURNED_STATUSES.sort).to eq ["Returned to Unit", "Unpacked"]
    end
  end

  describe "#auto_accept_days" do
    it "returns TechnicalMetadatumModule.format_auto_accept_days(format)" do
      expect(valid_po.auto_accept_days).to eq TechnicalMetadatumModule.format_auto_accept_days(valid_po.format)
    end
  end

  describe "provides virtual attributes:" do
    describe "#auto_accept" do
      context "when .digital_start is nil" do
        it "returns nil" do
          expect(valid_po.digital_start).to be_nil
          expect(valid_po.auto_accept).to be_nil
        end
      end
      context "when .digital_start is set" do
        before(:each) do
          valid_po.digital_start = Time.now
          video_po.digital_start = Time.now
          film_po.digital_start = Time.now
        end
        specify "for an audio format, returns audio delay" do
          expect(valid_po.auto_accept).not_to be_nil
          expect(valid_po.auto_accept).to eq (valid_po.digital_start + TechnicalMetadatumModule::GENRE_AUTO_ACCEPT_DAYS[:audio].days)
        end
        specify "for video format, returns video delay" do
          expect(video_po.auto_accept).not_to be_nil
          expect(video_po.auto_accept).to eq (video_po.digital_start + TechnicalMetadatumModule::GENRE_AUTO_ACCEPT_DAYS[:video].days)
        end
        specify "for film format, returns film  delay" do
          expect(film_po.auto_accept).not_to be_nil
          expect(film_po.auto_accept).to eq (film_po.digital_start + TechnicalMetadatumModule::GENRE_AUTO_ACCEPT_DAYS[:film].days)
        end
      end
    end
    it "#carrier_stream_index" do
      expect(valid_po.carrier_stream_index).to eq valid_po.group_identifier + "_1_1"
    end
    describe "#container_bin" do
      context "when boxed" do
        before(:each) do
	  box.bin = bin
	  box.save
	  boxable_po.box = box
	end
	it "returns the box's bin" do
	  expect(boxable_po.container_bin).to eq bin
	end
      end
      context "when binned" do
        before(:each) do
	  binnable_po.bin = bin
	end
	it "returns the bin" do
	  expect(binnable_po.container_bin).to eq bin
	end
      end
      context "when uncontained" do
        before(:each) do
	  valid_po.box = nil
	  valid_po.bin = nil
	end
	it "returns nil" do
	  expect(valid_po.container_bin).to be_nil
	end
      end
    end
    describe "#container_batch" do
      context "when boxed" do
        before(:each) do
          bin.batch = batch
          bin.save!
          box.bin = bin
          box.save!
          boxable_po.box = box
          boxable_po.save!
        end
        it "returns the box's bin's batch" do
          expect(boxable_po.container_batch).to eq batch
        end
      end
      context "when binned" do
        before(:each) do
          bin.batch = batch
          bin.save!
          binnable_po.bin = bin
        end
        it "returns the bin" do
          expect(binnable_po.container_batch).to eq batch
        end
      end
      context "when uncontained" do
        before(:each) do
          valid_po.box = nil
          valid_po.bin = nil
        end
        it "returns nil" do
          expect(valid_po.container_batch).to be_nil
        end
      end
    end

    it "#file_prefix" do
      expect(valid_po.file_prefix).to eq "MDPI_" + valid_po.mdpi_barcode.to_s
    end
    describe "#file_bext" do
      context "with collection_identifier" do
        before(:each) { valid_po.collection_identifier = "collection identifier" }
	context "with call_number" do
          let(:file_bext) { "Indiana University-Bloomington. #{valid_po.unit.name}. collection identifier. call number. File use: " }
	  before(:each) { valid_po.call_number = "call number" }
          it "returns correct text" do
            expect(valid_po.file_bext).to eq file_bext
          end
	end
	context "without call_number" do
	  let(:file_bext) { "Indiana University-Bloomington. #{valid_po.unit.name}. collection identifier. File use: " }
	  before(:each) { valid_po.call_number = "" }
	  it "returns correct text" do
	    expect(valid_po.file_bext).to eq file_bext
	  end
	end
      end
      context "without collection_identifier" do
        before(:each) { valid_po.collection_identifier = "" }
        context "with call_number" do
          let(:file_bext) { "Indiana University-Bloomington. #{valid_po.unit.name}. call number. File use: " }
          before(:each) { valid_po.call_number = "call number" }
          it "returns correct text" do
            expect(valid_po.file_bext).to eq file_bext
          end
        end
        context "without call_number" do
          let(:file_bext) { "Indiana University-Bloomington. #{valid_po.unit.name}. File use: " }
          before(:each) { valid_po.call_number = "" }
          it "returns correct text" do
            expect(valid_po.file_bext).to eq file_bext
          end
        end
      end
    end
    it "#file_icmt" do
      expect(valid_po.file_icmt).to eq valid_po.file_bext
    end
    it "#file_iarl" do
      expect(valid_po.file_iarl).to eq "Indiana University-Bloomington. #{valid_po.unit.name}."
    end
    describe "#generate_filename" do
      describe "infers extension from format" do
        specify ".wav for audio format" do
	  valid_po.format = "CD-R"
	  expect(valid_po.generate_filename).to match /\.wav$/
	end
	specify ".mkv for video format" do
	  valid_po.format = "Betacam"
	  expect(valid_po.generate_filename).to match /\.mkv$/
	end
	specify ".mkv for film format" do
	  valid_po.format = "Film"
	  expect(valid_po.generate_filename).to match /\.mkv$/
	end
	specify "defaults to nil for unknown format" do
	  valid_po.format = "Unknown format"
	  expect(valid_po.generate_filename).to match /\.$/
	end
      end
      context "with specified sequence, use, extension" do
        it "uses specified sequence, use, extension values" do
	  expect(valid_po.generate_filename(sequence: 42, use: 'use', extension: 'ext')).to eq "MDPI_#{valid_po.mdpi_barcode}_42_use.ext"
	end
      end
      context "with single-digit sequence" do
        it "pads sequence value" do
	  expect(valid_po.generate_filename(sequence: 4)).to eq "MDPI_#{valid_po.mdpi_barcode}_04_pres.wav"
	end
      end
      context "with more than 2-digit sequence" do
        it "uses full sequence value provided" do
	  expect(valid_po.generate_filename(sequence: 420)).to eq "MDPI_#{valid_po.mdpi_barcode}_420_pres.wav"
	end
      end
      context "with no arguments" do
        it "uses default sequence, use, extension values" do
          expect(valid_po.generate_filename).to eq "MDPI_#{valid_po.mdpi_barcode}_01_pres.wav"
	end
      end
      context "with nil arguments" do
        it "uses default sequence, use, extension values" do
          expect(valid_po.generate_filename(sequence: nil, use: nil, extension: nil)).to eq "MDPI_#{valid_po.mdpi_barcode}_01_pres.wav"
	end
      end
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
        bin.save!
        box.bin = bin
        box.save!
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
      let!(:active1) { FactoryBot.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Active 1", active: true, condition_status_template_id: cst_templates[0].id }
      let!(:active2) { FactoryBot.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Active 2", active: true, condition_status_template_id: cst_templates[1].id }
      let!(:inactive1) { FactoryBot.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Inactive 1", active: false, condition_status_template_id: cst_templates[2].id }
      let!(:inactive2) { FactoryBot.create :condition_status, physical_object_id: po.id, user: condition_user, notes: "Inactive 2", active: false, condition_status_template_id: cst_templates[3].id }
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
          let!(:external1) { FactoryBot.create :note, physical_object: po, export: true, body: "External 1", user: note_user }
          let!(:external2) { FactoryBot.create :note, physical_object: po, export: true, body: "External 2", user: note_user }
          let!(:internal1) { FactoryBot.create :note, physical_object: po, export: false, body: "Internal 1", user: note_user }
          let!(:internal2) { FactoryBot.create :note, physical_object: po, export: false, body: "Internal 2", user: note_user }
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
                   expect(po.master_copies).to eq po.technical_metadatum.specific.master_copies
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
          TechnicalMetadatumModule.tm_formats_array.each do |format|
            context "with valid format: #{format}" do
              let(:tm) { valid_po.create_tm(format) }
              it "creates a new TM" do
                expect(tm).to be_a_new(TechnicalMetadatumModule.tm_format_classes[format])
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

        it_behaves_like "includes ConditionStatusModule" do
          let(:condition_status) { FactoryBot.create(:condition_status, :physical_object, physical_object: po) }
          let(:target_object) { po }
          let(:class_title) { "Physical Object" }
        end

        status_list = ["Unassigned", "On Pick List", "Boxed", "Binned", "Unpacked", "Returned to Unit", "Re-send to Memnon"]
  # pass status_list arg here to test previous/next methods
  it_behaves_like "includes WorkflowStatusModule" do
    let(:object) { valid_po }
    let(:default_status) { "Unassigned" }
    let(:new_status) { "On Pick List" }
    let(:valid_status_values) { status_list }
    let(:class_title) { "Physical Object" }
  end

  include_examples "includes XMLExportModule", :title, :has_ephemera do
    let(:target_object) { valid_po }
  end

  describe "self.formats" do
    it "returns TechnicalMetadumModule.tm_formats_hash" do
      expect(PhysicalObject.formats).to eq TechnicalMetadatumModule.tm_formats_hash
    end
  end

#FIXME: add non-trivial scope tests?
  describe "scopes" do
    describe "packing_sort" do
      it "returns an PhysicalObject collection" do
        expect(PhysicalObject.packing_sort).to be_a ActiveRecord::Relation
      end
    end
    describe "unpacked" do
      it "returns an PhysicalObject collection" do
        expect(PhysicalObject.unpacked).to be_a ActiveRecord::Relation
      end
    end
    describe "unpacked_or_id(object_id)" do
      it "returns an PhysicalObject collection" do
        expect(PhysicalObject.unpacked_or_id(0)).to be_a ActiveRecord::Relation
      end
    end
    describe "packed" do
      it "returns an PhysicalObject collection" do
        expect(PhysicalObject.packed).to be_a ActiveRecord::Relation
      end
    end
    describe "blocked" do
      it "returns an PhysicalObject collection" do
        expect(PhysicalObject.blocked).to be_a ActiveRecord::Relation
      end
    end
    describe "search_by_barcode_title_call_number" do
      it "returns an PhysicalObject collection" do
        expect(PhysicalObject.search_by_barcode_title_call_number(0)).to be_a ActiveRecord::Relation
      end
    end
    describe "unstaged_formats_by_date_entity(date, entity)" do
      it "returns an array of formats" do
        expect(PhysicalObject.unstaged_formats_by_date_entity(Time.now, DigitalProvenance::IU_DIGITIZING_ENTITY)).to be_a Array
      end
    end
    describe "unstaged_by_date_format_entity(date, format, entity)" do
      it "returns an PhysicalObject collection" do
        expect(PhysicalObject.unstaged_by_date_format_entity(Time.now, 'CD-R', DigitalProvenance::IU_DIGITIZING_ENTITY)).to be_a ActiveRecord::Relation
      end
    end
    describe "collection_owner_filter(unit_id)" do
      it "returns a PhysicalObject collection" do
        expect(PhysicalObject.collection_owner_filter(1)).to be_a ActiveRecord::Relation
      end
    end
  end
  
  describe "#init_start_digital_status" do
    context "with a real barcode" do
      before(:each) { valid_po.mdpi_barcode = valid_mdpi_barcode }
      it "sets a digital_start time" do
        expect(valid_po.digital_start).to be_nil
        valid_po.init_start_digital_status
        expect(valid_po.digital_start).not_to be_nil
      end
      it "saves a digital_status" do
        expect(valid_po.digital_statuses).to be_empty
        valid_po.init_start_digital_status
        valid_po.reload
        expect(valid_po.digital_statuses).not_to be_empty
      end
    end
    context "with an invalid barcode" do
      before(:each) { valid_po.mdpi_barcode = invalid_mdpi_barcode }
      it "raises an error" do
        expect{valid_po.init_start_digital_status}.to raise_error RuntimeError
      end
    end
  end

  describe "#carrier_stream_index" do
    context "with no group key" do
      before(:each) { valid_po.group_key = nil }
      it "returns MISSING_1_1" do
        expect(valid_po.carrier_stream_index).to eq "MISSING_1_1"
      end
    end
    context "with a group key" do
      before(:each) { valid_po.ensure_group_key }
      it "returns (group_identifier)_(group_position)_(group_total)" do
        expect(valid_po.carrier_stream_index).to eq valid_po.group_key.group_identifier + "_" + valid_po.group_position.to_s + "_" + valid_po.group_key.group_total.to_s
      end
    end
  end

  describe "#digital_start_readable" do
    context "when digital_start is nil" do
      before(:each) { valid_po.digital_start = nil }
      it 'returns "Digitization Has Not Begun"' do
        expect(valid_po.digital_start_readable).to eq "Digitization Has Not Begun"
      end
    end
    context "when digital_start is not nil" do
      before(:each) { valid_po.digital_start = Time.now }
      it "returns formatted time string" do
        expect(valid_po.digital_start_readable).to match /\d:\d/
      end
    end
  end

  describe "#expires" do
    context "with no 'transferred' status" do
      it "returns nil" do
        expect(valid_po.digital_statuses).to be_empty
        expect(valid_po.expires).to be_nil
      end
    end
    context "with a transferred status" do
      let!(:created_at) { Time.now.change(nsec: 0) }
      before(:each) { barcoded_po.digital_statuses.create!(state: 'transferred', created_at: created_at) }
      before(:each) { barcoded_po.digital_start = created_at }
      { audio: { format: "CD-R", day_count: TechnicalMetadatumModule::GENRE_AUTO_ACCEPT_DAYS[:audio] },
        video: { format: "Betacam", day_count: TechnicalMetadatumModule::GENRE_AUTO_ACCEPT_DAYS[:video]},
        film: { format: "Film", day_count: TechnicalMetadatumModule::GENRE_AUTO_ACCEPT_DAYS[:film]}
      }.each do |genre, values|
        context "for #{genre} format" do
          before(:each) { barcoded_po.format = values[:format] }
          it "returns start date plus #{values[:day_count]} days" do
            expect(barcoded_po.expires).to eq (created_at + values[:day_count].days)
          end
        end
      end
    end
  end

  describe "#physical_object_query" do
    skip "indirectly tested by picklist_specifications#query controller spec"
  end

  describe "::physical_object_query" do
    skip "indirectly tested by search#advanced_search controller spec"
  end

  describe "#workflow_blocked?" do
    context "with no condition statuses"
    context "with condition statuses" do
      { {active: true, blocks_packing: true } => true,
        {active: true, blocks_packing: false } => false,
        {active: false, blocks_packing: true } => false,
        {active: false, blocks_packing: false } => false }.each do |values, result|
        describe "with #{values.inspect}" do
          it "returns #{result}" do
            temp_cs = FactoryBot.build :condition_status, :physical_object, **values
            cs = po.condition_statuses.new
            cs.assign_attributes(active: temp_cs.active, condition_status_template_id: temp_cs.condition_status_template_id)
            cs.save!
            expect(po.workflow_blocked?).to eq result
          end
        end
      end
    end
  end

  describe "#current_digital_status" do
    context "with no digital statuses" do
      before(:each) { expect(valid_po.digital_statuses).to be_empty }
      it "returns nil" do
        expect(valid_po.current_digital_status).to be_nil
      end
    end
    context "with multiple digital statuses" do
      before(:each) do
        valid_po.digital_statuses.new(state: 'initial')
        valid_po.digital_statuses.new(state: 'final')
        expect(valid_po.digital_statuses.size).to be > 1
      end
      it "returns last status" do
        expect(valid_po.current_digital_status).not_to be_nil
        expect(valid_po.current_digital_status.state).to eq 'final'
      end
    end
  end

  describe "#ensure_digiprov" do
    context "with no digital_provenance" do
      before(:each) { valid_po.digital_provenance = nil }
      it "builds and assigns a new digital_provenance" do
        expect(valid_po.digital_provenance).to be_nil
        expect(valid_po.ensure_digiprov).to be_a DigitalProvenance
        expect(valid_po.digital_provenance).not_to be_nil
      end
    end
    context "with a digital_provenance" do
      let(:original_dp) { FactoryBot.build :digital_provenance, physical_object: valid_po, comments: "original dp" }
      before(:each) { valid_po.digital_provenance = original_dp }
      it "returns the existing provenance" do
        expect(valid_po.digital_provenance).to eq original_dp
        expect(valid_po.ensure_digiprov).to eq original_dp
        expect(valid_po.digital_provenance).to eq original_dp
      end
    end
  end

  describe "#validate_bin_container" do
    context "with no bin" do
      before(:each) { valid_po.bin = nil }
      it "returns nil" do
        expect(valid_po.validate_bin_container).to be_nil
      end
      it "does not assign any errors" do
        expect(valid_po.errors[:base]).to be_empty
        valid_po.validate_bin_container
        expect(valid_po.errors[:base]).to be_empty
      end
    end
    context "with a bin" do
      before(:each) do
        valid_po.mdpi_barcode = valid_mdpi_barcode
        valid_po.format = TechnicalMetadatumModule.bin_formats.first
        valid_po.bin = bin
      end
      context "without a barcode" do
        before(:each) { valid_po.mdpi_barcode = nil }
        it "adds an error" do
          valid_po.validate_bin_container
          expect(valid_po.errors[:base].first).to match /object must be assigned a barcode/
        end
      end
      context "with an unbinnable format" do
        before(:each) { valid_po.format = TechnicalMetadatumModule.box_formats.first }
        it "adds an error" do
          valid_po.validate_bin_container
          expect(valid_po.errors[:base].first).to match /format.*cannot be assigned/
        end
      end
      context "already containing boxes" do
        before(:each) { box.bin = bin; box.save! }
        it "adds an error" do
          valid_po.validate_bin_container
          expect(valid_po.errors[:base].first).to match /contains boxes/
        end
      end
      context "already containing a different format" do
        before(:each) { bin.format = TechnicalMetadatumModule.bin_formats.last; bin.save! }
        it "adds an error" do
          valid_po.validate_bin_container
          expect(valid_po.errors[:base].first).to match /different format/
        end
      end
      context "(empty)" do
        it "does not add an error" do
          expect(bin.boxes).to be_empty
          expect(bin.physical_objects).to be_empty
          valid_po.validate_bin_container
          expect(valid_po.errors[:base]).to be_empty
        end
      end
      context "(matching format)" do
        before(:each) { bin.format = valid_po.format; bin.save! }
        it "does not add an error" do
          valid_po.validate_bin_container
          expect(valid_po.errors[:base]).to be_empty
        end
      end
    end
  end

  describe "#validate_box_container" do
    context "with no box" do
      before(:each) { valid_po.box = nil }
      it "returns nil" do
        expect(valid_po.validate_box_container).to be_nil
      end
      it "does not assign any errors" do
        expect(valid_po.errors[:base]).to be_empty
        valid_po.validate_box_container
        expect(valid_po.errors[:base]).to be_empty
      end
    end
    context "with a box" do
      before(:each) do
        valid_po.mdpi_barcode = valid_mdpi_barcode
        valid_po.format = TechnicalMetadatumModule.box_formats.first
        valid_po.box = box
      end
      context "without a barcode" do
        before(:each) { valid_po.mdpi_barcode = nil }
        it "adds an error" do
          valid_po.validate_box_container
          expect(valid_po.errors[:base].first).to match /object must be assigned a barcode/
        end
      end
      context "with an unboxable format" do
        before(:each) { valid_po.format = TechnicalMetadatumModule.bin_formats.first }
        it "adds an error" do
          valid_po.validate_box_container
          expect(valid_po.errors[:base].first).to match /format.*cannot be assigned/
        end
      end
      context "already containing a different format" do
        before(:each) { box.format = TechnicalMetadatumModule.box_formats.last; box.save! }
        it "adds an error" do
          valid_po.validate_box_container
          expect(valid_po.errors[:base].first).to match /different format/
        end
      end
      context "(empty)" do
        it "does not add an error" do
          expect(box.physical_objects).to be_empty
          valid_po.validate_box_container
          expect(valid_po.errors[:base]).to be_empty
        end
      end
      context "(matching format)" do
        before(:each) { box.format = valid_po.format; box.save! }
        it "does not add an error" do
          valid_po.validate_box_container
          expect(valid_po.errors[:base]).to be_empty
        end
      end
    end
  end

  describe "#apply_resend_status" do
    let(:original_statuses) { po.workflow_statuses.map { |s| s.workflow_status_template.name } }
    let(:final_statuses) { po.workflow_statuses.map { |s| s.workflow_status_template.name } }
    it "adds at least 2 status entries" do
      original_statuses
      po.apply_resend_status
      final_statuses
      expect(final_statuses.size).to be >= (original_statuses.size + 2)
    end
    it "adds an entry for resending status" do
      expect(original_statuses).not_to include 'Re-send to Memnon'
      po.apply_resend_status
      expect(final_statuses).to include 'Re-send to Memnon'
    end
    it "adds an entry for Unassigned status" do
      po.apply_resend_status
      expect(final_statuses[-2,2]).to include 'Unassigned'
    end
    it "adds an entry for the inferred status" do
      po.picklist = picklist
      po.save!
      po.apply_resend_status
      expect(final_statuses[-1]).to eq 'On Pick List'
      expect(final_statuses[-2]).to eq 'Unassigned'
      expect(final_statuses[-3]).to eq 'Re-send to Memnon'
    end
    it "clears out the billing flags" do
      po.update_attributes!(billed: true, date_billed: Time.now)
      po.apply_resend_status
      expect(po.billed).to eq false
      expect(po.date_billed).to be_nil
    end
    it "adds note about change" do
      expect { po.apply_resend_status }.to change(Note, :count).by(1)
    end
  end

  describe "private methods" do
# .physical_object_search
# .add_search_terms
    shared_examples "tm_table_name examples" do
      describe "#tm_table_name(format)" do
        context "with a valid format" do
          let(:format) { TechnicalMetadatumModule.tm_formats_array.first }
          it "returns a table name" do
            expect(subject.send(:tm_table_name,format)).to eq TechnicalMetadatumModule.tm_table_names[format]
            expect(subject.send(:tm_table_name,format)).to be_a String
            expect(subject.send(:tm_table_name,format)).not_to be_blank
          end
        end
        context "with an invalid format" do
           let(:format) { "Invalid format" }
           it "raises an error" do
             expect{ subject.send(:tm_table_name,format) }.to raise_error RuntimeError
           end
        end
      end
    end
    describe "for class:" do
      let(:subject) { PhysicalObject }
      include_examples "tm_table_name examples"
    end
    describe "for object:" do
      let(:subject) { valid_po }
      include_examples "tm_table_name examples"
    end
    describe "#default_values" do
      [:generation, :group_position, :mdpi_barcode, :digital_provenance].each do |att|
        specify "sets #{att}" do
          valid_po.send(att.to_s + "=", nil)
          expect(valid_po.send(att)).to be_nil
          valid_po.send(:default_values)
          expect(valid_po.send(att)).not_to be_nil
        end
      end
    end
  end
end
