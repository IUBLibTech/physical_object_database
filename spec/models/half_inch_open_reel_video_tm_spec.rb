describe HalfInchOpenReelVideoTm do
  let(:half_inch_open_reel_video) { FactoryBot.create :half_inch_open_reel_video_tm, :valid }
  let(:valid_half_inch_open_reel_video) { FactoryBot.build :half_inch_open_reel_video_tm, :valid }
  let(:invalid_half_inch_open_reel_video) { FactoryBot.build :half_inch_open_reel_video_tm, :invalid }

  describe "FactoryBot" do
    it "provides a valid object" do
      expect(half_inch_open_reel_video).to be_valid
      expect(valid_half_inch_open_reel_video).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_half_inch_open_reel_video).not_to be_valid
    end
  end

  describe "has validated fields:" do
    [:format_version, :recording_standard, :image_format, :pack_deformation].each do |field|
      specify "#{field} value in list" do
        valid_half_inch_open_reel_video.send(field.to_s + "=", "invalid value")
        expect(valid_half_inch_open_reel_video).not_to be_valid
      end
    end
  end

  describe "has virtual fields:" do
    specify "#damage for pack_deformation" do
      expect(valid_half_inch_open_reel_video.damage).to eq valid_half_inch_open_reel_video.pack_deformation
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_half_inch_open_reel_video.manifest_headers).to eq []
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:half_inch_open_reel_video_tm, :valid)

  describe "#master_copies" do
    it "returns 1" do
      expect(valid_half_inch_open_reel_video.master_copies).to eq 1
    end
  end

  describe 'digital provenance requirements' do
    specify 'have customized list' do      
      expect(described_class::DIGITAL_PROVENANCE_FILES).to eq ['Digital Master', 'PresInt']
    end
  end
end
