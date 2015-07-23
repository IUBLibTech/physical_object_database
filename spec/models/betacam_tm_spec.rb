require 'rails_helper'

describe BetacamTm do
  let(:betacam) { FactoryGirl.create :betacam_tm, :valid }
  let(:valid_betacam) { FactoryGirl.build :betacam_tm, :valid }
  let(:invalid_betacam) { FactoryGirl.build :betacam_tm, :invalid }

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(betacam).to be_valid
      expect(valid_betacam).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_betacam).not_to be_valid
    end
  end

  describe "has validated fields:" do
    [:pack_deformation, :cassette_size, :recording_standard, :format_duration, :image_format].each do |field|
      specify "#{field} value in list" do
        valid_betacam.send(field.to_s + "=", "invalid value")
        expect(valid_betacam).not_to be_valid
      end
    end
  end

  describe "has virtual fields:" do
    specify "#damage for pack_deformation" do
      expect(valid_betacam.damage).to eq valid_betacam.pack_deformation
    end
    specify "#year" do
      physical_object = FactoryGirl.create(:physical_object, :betacam, year: 1985)
      valid_betacam.technical_metadatum.physical_object = physical_object
      expect(valid_betacam.year).to eq 1985
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_betacam.manifest_headers).to eq ["Year", "Recording standard", "Image format", "Tape stock brand", "Size", "Format duration"]
    end
  end

end
