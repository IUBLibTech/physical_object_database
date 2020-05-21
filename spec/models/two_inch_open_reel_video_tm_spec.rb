describe TwoInchOpenReelVideoTm do
  let(:two_inch_open_reel_video) { FactoryBot.create :two_inch_open_reel_video_tm, :valid }
  let(:valid_two_inch_open_reel_video) { FactoryBot.build :two_inch_open_reel_video_tm, :valid }
  let(:invalid_two_inch_open_reel_video) { FactoryBot.build :two_inch_open_reel_video_tm, :invalid }

  describe "FactoryBot" do
    it "provides a valid object" do
      expect(two_inch_open_reel_video).to be_valid
      expect(valid_two_inch_open_reel_video).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_two_inch_open_reel_video).not_to be_valid
    end
  end

  describe "has validated fields:" do
    [:recording_standard, :format_duration, :reel_type, :format_version, :recording_mode, :pack_deformation, :cue_track_contains, :sound_field].each do |field|
      specify "#{field} value in list" do
        valid_two_inch_open_reel_video.send(field.to_s + "=", "invalid value")
        expect(valid_two_inch_open_reel_video).not_to be_valid
      end
    end
  end

  describe "has default values" do
    { recording_standard: 'NTSC',
      format_duration: 'Unknown',
      reel_type: 'metal reel',
      format_version: 'Quadruplex',
      pack_deformation: 'None',
      cue_track_contains: 'Silence',
      sound_field: 'Mono',
    }.each do |field, value|
      specify "#{field}: #{value}" do
        valid_two_inch_open_reel_video.send("#{field}=", nil)
        valid_two_inch_open_reel_video.default_values
        expect(valid_two_inch_open_reel_video.send(field)).to eq value
      end
    end
  end

  describe "has virtual fields:" do
    specify "#damage for pack_deformation" do
      expect(valid_two_inch_open_reel_video.damage).to eq valid_two_inch_open_reel_video.pack_deformation
    end
  end

  # FIXME: verify
  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_two_inch_open_reel_video.manifest_headers).to eq ["Recording standard", "Format duration", "Reel type", "Format version", "Recording mode", "Tape stock brand"]
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:two_inch_open_reel_video_tm, :valid)

  describe "#master_copies" do
    it "returns 1" do
      expect(valid_two_inch_open_reel_video.master_copies).to eq 1
    end
  end

  describe "has optional fields" do
    [:tape_stock_brand, :structural_damage].each do |field|
      specify "#{field}" do
        valid_two_inch_open_reel_video.send("#{field}=", nil)
        expect(valid_two_inch_open_reel_video).to be_valid
      end
    end
  end

  describe 'digital provenance requirements' do
    specify 'have customized list' do      
      expect(described_class::DIGITAL_PROVENANCE_FILES).to eq ['Digital Master', 'PresInt']
    end
  end
end
