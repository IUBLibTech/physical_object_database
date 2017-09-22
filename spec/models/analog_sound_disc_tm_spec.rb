describe AnalogSoundDiscTm do

  let(:analog_sound_disc_tm) {FactoryGirl.build :analog_sound_disc_tm }

  it "gets a valid object from FactoryGirl" do
    expect(analog_sound_disc_tm).to be_valid
  end

  describe "has required fields:" do
    specify "diameter in values list" do
      analog_sound_disc_tm.diameter = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "speed in values list" do
      analog_sound_disc_tm.speed = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "groove_size in values list" do
      analog_sound_disc_tm.groove_size = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "groove_orientation in values list" do
      analog_sound_disc_tm.groove_orientation = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "sound_field in values list" do
      analog_sound_disc_tm.sound_field = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "recording_method in values list" do
      analog_sound_disc_tm.recording_method = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "material in values list" do
      analog_sound_disc_tm.material = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "substrate in values list" do
      analog_sound_disc_tm.substrate = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "coating in values list" do
      analog_sound_disc_tm.coating = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "equalization in values list" do
      analog_sound_disc_tm.equalization = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
    specify "subtype in values list" do
      analog_sound_disc_tm.subtype = "invalid value"
      expect(analog_sound_disc_tm).not_to be_valid
    end
  end

  describe "has optional fields:" do
    specify "country of origin" do
      analog_sound_disc_tm.country_of_origin = nil
      expect(analog_sound_disc_tm).to be_valid
    end
    specify "label" do
      analog_sound_disc_tm.label = nil
      expect(analog_sound_disc_tm).to be_valid
    end
  end

  describe "has virtual fields" do
    let(:year) { '1985' }
    specify "#year" do
      physical_object = FactoryGirl.create(:physical_object, :lp, year: year)
      analog_sound_disc_tm.physical_object = physical_object
      expect(analog_sound_disc_tm.year).to eq year
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(analog_sound_disc_tm.manifest_headers).to eq ["Year", "Label", "Diameter in inches", "Recording type", "Groove type", "Playback speed", "Equalization"]
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryGirl.build(:analog_sound_disc_tm) 
  it_behaves_like "includes YearModule", FactoryGirl.build(:analog_sound_disc_tm)

  describe "#master_copies" do
    it "returns 2" do
      expect(analog_sound_disc_tm.master_copies).to eq 2
    end
  end

  describe "has subtypes" do
    ['LP', 'Aluminum Disc', 'Lacquer Disc', 'Other Analog Sound Disc', '45', '78'].each do |subtype|
      describe subtype do
        it "is a listed subtype option" do
	  expect(AnalogSoundDiscTm::SUBTYPE_VALUES.keys).to include subtype
	end
	it "has associated default values" do
	  expect(AnalogSoundDiscTm::DEFAULT_VALUES.keys).to include subtype
	end
      end
    end
  end

  describe "#default_values" do
    context "with no subtype set" do
      before(:each) { analog_sound_disc_tm.subtype = nil }
      it "does nothing" do
        analog_sound_disc_tm.diameter = nil
        analog_sound_disc_tm.default_values
        expect(analog_sound_disc_tm.diameter).to be_nil
      end
    end
    context "with a subtype set" do
      before(:each) { analog_sound_disc_tm.subtype = AnalogSoundDiscTm::TM_FORMAT.first }
      it "assigns default values" do
        analog_sound_disc_tm.diameter = nil
        analog_sound_disc_tm.default_values
        expect(analog_sound_disc_tm.diameter).not_to be_nil
      end
    end
  end

end

