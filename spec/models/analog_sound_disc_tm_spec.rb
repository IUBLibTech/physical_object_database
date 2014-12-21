require 'rails_helper'

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

  it_behaves_like "includes technical metadatum behaviors", FactoryGirl.build(:analog_sound_disc_tm) 

  describe "#master_copies" do
    it "returns 2" do
      expect(analog_sound_disc_tm.master_copies).to eq 2
    end
  end

end

