describe DigitalFileProvenance do
  let(:new_dfp) { DigitalFileProvenance.new }
  let(:dfp) { FactoryGirl.create :digital_file_provenance }
  let(:valid_dfp) { FactoryGirl.build(:digital_file_provenance, digital_provenance: FactoryGirl.build(:digital_provenance), signal_chain:(FactoryGirl.build :signal_chain)) }
  before(:each) do
    valid_dfp.signal_chain.signal_chain_formats.new(format: valid_dfp.digital_provenance.physical_object.format)
  end
  let(:invalid_dfp) { FactoryGirl.build(:digital_file_provenance, :invalid, digital_provenance: FactoryGirl.build(:digital_provenance), signal_chain:(FactoryGirl.build :signal_chain)) }
  describe "has default values" do
    specify "created_by" do
      expect(new_dfp.created_by).not_to be_blank
    end
    specify "date_digitized" do
      expect(new_dfp.date_digitized).not_to be_nil
    end
    specify "tape_fluxivity" do
      expect(new_dfp.tape_fluxivity).to eq 250
    end
    specify "analog_output_voltage" do
      expect(new_dfp.analog_output_voltage).to eq "+4"
    end
    specify "peak" do
      expect(new_dfp.peak).to eq -18
    end
  end

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_dfp).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_dfp).not_to be_valid
    end
  end
  
  describe "has required attributes:" do
    describe "filename" do
      let(:barcode) { valid_dfp.digital_provenance.physical_object.mdpi_barcode }
      it "must be provided" do
        valid_dfp.filename = ""
        expect(valid_dfp).not_to be_valid
      end
      it "must be unique" do
        dup_dfp = dfp.dup
        expect(dup_dfp).not_to be_valid
      end
      it "must start with MDPI" do
        valid_dfp.filename = "FOO_#{barcode}_01_pres.wav"
        expect(valid_dfp).not_to be_valid
      end
      it "must have a matching barcode" do
        valid_dfp.filename = "MDPI_#{barcode.to_s.sub('4','2')}_01_pres.wav"
        expect(valid_dfp).not_to be_valid
      end
      it "must have a valid sequence number" do
        valid_dfp.filename = "MDPI_#{barcode}_1_pres.wav"
        expect(valid_dfp).not_to be_valid
        valid_dfp.filename = "MDPI_#{barcode}_001_pres.wav"
        expect(valid_dfp).not_to be_valid
      end
      it "must have a valid use" do
        valid_dfp.filename = "MDPI_#{barcode}_01_invalid.wav"
        expect(valid_dfp).not_to be_valid
      end
      it "must have a valid extension" do
        valid_dfp.filename = "MDPI_#{barcode}_01_pres.mkv"
        expect(valid_dfp).not_to be_valid
      end
      it "accepts a valid filename" do
        valid_dfp.filename = "MDPI_#{barcode}_01_pres.wav"
        expect(valid_dfp).to be_valid
      end
      it "accepts an object-generated filename" do
        valid_dfp.filename = valid_dfp.digital_provenance.physical_object.generate_filename
        expect(valid_dfp).to be_valid
      end
    end
    describe "created_by" do
      it "must be present" do
        valid_dfp.created_by = nil
        expect(valid_dfp).not_to be_valid
      end
    end
    describe "date_digitized" do
      it "must be present" do
        valid_dfp.date_digitized = nil
        expect(valid_dfp).not_to be_valid
      end
    end
    describe "tape_fluxivity" do
      it "must be greater than 0" do
        valid_dfp.tape_fluxivity = 0
        expect(valid_dfp).not_to be_valid
      end
    end
    describe "analog_output_voltage" do
      it "must be a signed decimal value" do
        valid_dfp.analog_output_voltage = "2"
        expect(valid_dfp).not_to be_valid
        valid_dfp.analog_output_voltage = "+2"
        expect(valid_dfp).to be_valid
        valid_dfp.analog_output_voltage = "-2"
        expect(valid_dfp).to be_valid
        valid_dfp.analog_output_voltage = "asdasd"
        expect(valid_dfp).not_to be_valid
      end
    end
    describe "peak" do
      it "must be less than 0" do
        valid_dfp.peak = 0
        expect(valid_dfp).not_to be_valid
        valid_dfp.peak = -1
        expect(valid_dfp).to be_valid
      end
    end
    describe "rumble_filter" do
      it "must be greater than 0" do
        valid_dfp.rumble_filter = 0
        expect(valid_dfp).not_to be_valid
      end
    end
    describe "reference_tone_frequency" do
      it "must be greater than 0" do
        valid_dfp.reference_tone_frequency = 0
        expect(valid_dfp).not_to be_valid
      end
    end

    describe "newly initialize" do
      it "is invalid" do
        n = DigitalFileProvenance.new
        expect(n).not_to be_valid
      end
    end
  end
  describe "has relationships:" do
    describe "digital provenance" do
      it "belongs to" do
        expect(valid_dfp).to respond_to :digital_provenance
      end
      it "must have" do
        valid_dfp.digital_provenance = nil
        expect(valid_dfp).not_to be_valid
      end
    end
    describe "signal chain" do
      let(:signal_chain) { FactoryGirl.build :signal_chain }
      it "belongs to" do
        expect(valid_dfp).to respond_to :signal_chain_id
      end
      it "is optional" do
        valid_dfp.signal_chain = nil
        expect(valid_dfp).to be_valid
      end
      it "must match format" do
        expect(valid_dfp).to be_valid
        valid_dfp.signal_chain = signal_chain
        expect(signal_chain.formats).not_to include valid_dfp.digital_provenance.physical_object.format
        expect(valid_dfp).not_to be_valid
      end
    end
  end

  describe "accepts blanks" do
    it "validates on blank tape_fluxivity, analog_output_voltage, and peak" do
      valid_dfp.tape_fluxivity = ""
      valid_dfp.analog_output_voltage = ""
      valid_dfp.peak = ""
      valid_dfp.signal_chain = nil
      expect(valid_dfp).to be_valid
    end
  end

  describe "#complete?" do
    it "returns a Boolean" do
      expect(valid_dfp.complete?).to be_in [true, false]
    end
  end

  describe "#nullify_na_values" do
    it "nullifies an na value as defined by the TM" do
      expect(valid_dfp.tape_fluxivity).not_to be_nil
      valid_dfp.nullify_na_values
      expect(valid_dfp.digital_provenance.physical_object.ensure_tm.provenance_requirements[:tape_fluxivity]).to be_nil
      expect(valid_dfp.tape_fluxivity).to be_nil
    end
    it "leaves alone required/optional values as defined by the TM" do
      expect(valid_dfp.tape_fluxivity).not_to be_nil
      valid_dfp.digital_provenance.physical_object.format = "Open Reel Audio Tape"
      valid_dfp.nullify_na_values
      expect(valid_dfp.tape_fluxivity).not_to be_nil
    end
    it "leaves alone values if no TM can be referenced" do
      expect(valid_dfp.tape_fluxivity).not_to be_nil
      valid_dfp.digital_provenance = nil
      valid_dfp.nullify_na_values
      expect(valid_dfp.tape_fluxivity).not_to be_nil
    end
    it "is called before save" do
      dfp.tape_fluxivity = "100"
      expect(dfp.tape_fluxivity).not_to be_nil
      dfp.save!
      expect(dfp.tape_fluxivity).to be_nil
    end
  end

  describe "filename operations" do
    describe "#file_use" do
      it "extracts the use portion" do
        expect(valid_dfp.file_use).to eq 'pres'
      end
    end
    describe "#full_file_use" do
      it "looks up the full file use description" do
        expect(valid_dfp.full_file_use).to eq 'Preservation Master'
      end
    end
    describe "#file_prefix" do
      it "returns the filename without extension (or preceding period)" do
        expect(valid_dfp.file_prefix).not_to be_blank
        expect(valid_dfp.file_prefix + ".wav").to match valid_dfp.filename
      end
    end
    describe "#file_ext" do
      it "returns the file extension (without preceding period)" do
        expect(valid_dfp.file_ext).to eq "wav"
      end
    end
    describe "#digital_file_bext" do
      it "returns '[file_bext][full_file_use]. [file_prefix]" do
        expect(valid_dfp.digital_file_bext).to eq "#{valid_dfp.digital_provenance.physical_object.file_bext}#{valid_dfp.full_file_use}. #{valid_dfp.file_prefix}"
      end
    end
  end

  describe "class constants:" do
    describe "FILE-USE_HASH" do
      it "is a Hash" do
        expect(DigitalFileProvenance::FILE_USE_HASH).to be_a Hash
      end
      it "is not empty" do
        expect(DigitalFileProvenance::FILE_USE_HASH).not_to be_empty
      end
    end
    describe "FILE_USE_VALUES" do
      it "is an Array" do
        expect(DigitalFileProvenance::FILE_USE_VALUES).to be_a Array
      end
      it "is not empty" do
        expect(DigitalFileProvenance::FILE_USE_VALUES).not_to be_empty
      end
    end
  end

  describe "#display_date_digitized" do
    let(:time) { Time.now }
    context "when blank" do
      before(:each) { valid_dfp.date_digitized = nil }
      it "returns empty string" do
        expect(valid_dfp.display_date_digitized).to eq ''
      end
    end
    context "when set to a value" do
      before(:each) { valid_dfp.date_digitized = time }
      it "returns empty string" do
        expect(valid_dfp.display_date_digitized).to eq time.in_time_zone("UTC").strftime("%m/%d/%Y")
      end
    end
  end
  describe "#display_date_digitized=(value)" do
    let!(:time) { Time.now.change(min: 0, sec: 0, nsec: 0) }
    let!(:new_time) { time - 1.days }
    before(:each) { valid_dfp.date_digitized = time }
    context "when value is nil" do
      it "returns nil" do
        expect(valid_dfp.display_date_digitized = nil).to eq nil
        expect(valid_dfp.date_digitized).to eq time
      end
    end
    context "when value is ''" do
      it "returns nil" do
        expect(valid_dfp.display_date_digitized = '').to eq ''
        expect(valid_dfp.date_digitized).to eq time
      end
    end
    context "when value is a date" do
      it "sets time" do
        valid_dfp.display_date_digitized = new_time.in_time_zone("UTC").strftime("%m/%d/%Y")
        expect(valid_dfp.date_digitized).not_to eq time
      end
    end
  end
end
