describe BetacamTm do
  let(:betacam) { FactoryBot.create :betacam_tm, :valid }
  let(:valid_betacam) { FactoryBot.build :betacam_tm, :valid }
  let(:invalid_betacam) { FactoryBot.build :betacam_tm, :invalid }

  describe "FactoryBot" do
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
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_betacam.manifest_headers).to eq ["Year", "Recording standard", "Image format", "Tape stock brand", "Size", "Format duration"]
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:betacam_tm, :valid)
  it_behaves_like "includes YearModule", FactoryBot.build(:betacam_tm, :valid)

  describe "#master_copies" do
    it "returns 1" do
      expect(valid_betacam.master_copies).to eq 1
    end
  end

  describe 'digital provenance requirements' do
    specify 'have customized list' do      
      expect(described_class::DIGITAL_PROVENANCE_FILES).to eq ['Digital Master', 'PresInt']
    end
  end
end
