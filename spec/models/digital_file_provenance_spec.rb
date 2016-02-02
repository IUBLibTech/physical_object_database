describe DigitalFileProvenance do
  let(:new_dfp) { DigitalFileProvenance.new }
  let(:dfp) { FactoryGirl.create :digital_file_provenance }
  let(:valid_dfp) { FactoryGirl.build(:digital_file_provenance, digital_provenance: FactoryGirl.build(:digital_provenance), signal_chain:(FactoryGirl.build :signal_chain)) }
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
      it "belongs to" do
        expect(valid_dfp).to respond_to :signal_chain_id
      end
      it "is optional" do
        valid_dfp.signal_chain = nil
        expect(valid_dfp).to be_valid
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
end
