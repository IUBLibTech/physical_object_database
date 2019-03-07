describe AnalogSoundDiscImagingTm do

  let(:analog_sound_disc_imaging_tm) {FactoryBot.build :analog_sound_disc_imaging_tm }

  it "gets a valid object from FactoryBot" do
    expect(analog_sound_disc_imaging_tm).to be_valid
  end

  describe "has required fields:" do
    specify "diameter in values list" do
      analog_sound_disc_imaging_tm.diameter = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "speed in values list" do
      analog_sound_disc_imaging_tm.speed = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "groove_size in values list" do
      analog_sound_disc_imaging_tm.groove_size = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "groove_orientation in values list" do
      analog_sound_disc_imaging_tm.groove_orientation = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "sound_field in values list" do
      analog_sound_disc_imaging_tm.sound_field = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "recording_method in values list" do
      analog_sound_disc_imaging_tm.recording_method = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "material in values list" do
      analog_sound_disc_imaging_tm.material = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "substrate in values list" do
      analog_sound_disc_imaging_tm.substrate = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "coating in values list" do
      analog_sound_disc_imaging_tm.coating = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "equalization in values list" do
      analog_sound_disc_imaging_tm.equalization = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
    specify "subtype in values list" do
      analog_sound_disc_imaging_tm.subtype = "invalid value"
      expect(analog_sound_disc_imaging_tm).not_to be_valid
    end
  end

  describe "has optional fields:" do
    specify "country of origin" do
      analog_sound_disc_imaging_tm.country_of_origin = nil
      expect(analog_sound_disc_imaging_tm).to be_valid
    end
    specify "label" do
      analog_sound_disc_imaging_tm.label = nil
      expect(analog_sound_disc_imaging_tm).to be_valid
    end
  end

  describe "has virtual fields" do
    let(:year) { '1985' }
    specify "#year" do
      physical_object = FactoryBot.create(:physical_object, :lp, year: year)
      analog_sound_disc_imaging_tm.physical_object = physical_object
      expect(analog_sound_disc_imaging_tm.year).to eq year
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(analog_sound_disc_imaging_tm.manifest_headers).to eq ["Year", "Label", "Diameter in inches", "Recording type", "Groove type", "Playback speed", "Equalization"]
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:analog_sound_disc_imaging_tm) 
  it_behaves_like "includes YearModule", FactoryBot.build(:analog_sound_disc_imaging_tm)

  describe "#master_copies" do
    it "returns 2" do
      expect(analog_sound_disc_imaging_tm.master_copies).to eq 2
    end
  end

  describe "#default_values" do
    context "with no subtype set" do
      before(:each) { analog_sound_disc_imaging_tm.subtype = nil }
      it "does nothing" do
        analog_sound_disc_imaging_tm.diameter = nil
        analog_sound_disc_imaging_tm.default_values
        expect(analog_sound_disc_imaging_tm.diameter).to be_nil
      end
    end
    context "with a subtype set" do
      before(:each) { analog_sound_disc_imaging_tm.subtype = 'Lacquer Disc-imaging' }
      it "assigns default values" do
        analog_sound_disc_imaging_tm.groove_orientation = nil
        analog_sound_disc_imaging_tm.default_values
        expect(analog_sound_disc_imaging_tm.groove_orientation).not_to be_nil
      end
    end
  end

  describe 'digital provenance requirements' do
    specify 'have customized list' do
      expect(described_class::DIGITAL_PROVENANCE_FILES).to eq ['Digital Master', 'PresInt', 'Prod', 'Access', 'Miscellaneous']
    end
  end
end

