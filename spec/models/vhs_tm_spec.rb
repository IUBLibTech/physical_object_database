describe VhsTm do
  let(:vhs) { FactoryBot.create :vhs_tm, :valid }
  let(:valid_vhs) { FactoryBot.build :vhs_tm, :valid }
  let(:invalid_vhs) { FactoryBot.build :vhs_tm, :invalid }

  describe "FactoryBot" do
    it "provides a valid object" do
      expect(vhs).to be_valid
      expect(valid_vhs).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_vhs).not_to be_valid
    end
  end

  describe "has validated fields:" do
    [:format_version, :recording_standard, :playback_speed, :size, :image_format, :pack_deformation].each do |field|
      specify "#{field} value in list" do
        valid_vhs.send(field.to_s + "=", "invalid value")
        expect(valid_vhs).not_to be_valid
      end
    end
  end

  describe "has required fields:" do
    [:format_duration].each do |field|
      specify field do
        valid_vhs.send(field.to_s + "=", nil)
        expect(valid_vhs).not_to be_valid
      end
    end
  end

  describe "has virtual fields:" do
    specify "#damage for pack_deformation" do
      expect(valid_vhs.damage).to eq valid_vhs.pack_deformation
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_vhs.manifest_headers).to eq ["Format version", "Recording standard", "Format duration", "Playback speed"]
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:vhs_tm, :valid)

  describe "#master_copies" do
    it "returns 1" do
      expect(valid_vhs.master_copies).to eq 1
    end
  end

  describe 'digital provenance requirements' do
    specify 'have customized list' do      
      expect(described_class::DIGITAL_PROVENANCE_FILES).to eq ['Digital Master', 'PresInt']
    end
  end
end
