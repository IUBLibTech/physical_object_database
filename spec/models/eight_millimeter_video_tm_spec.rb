describe EightMillimeterVideoTm do
  let(:eight_mm) { FactoryGirl.create :eight_mm_tm, :valid }
  let(:valid_eight_mm) { FactoryGirl.build :eight_mm_tm, :valid }
  let(:invalid_eight_mm) { FactoryGirl.build :eight_mm_tm, :invalid }

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(eight_mm).to be_valid
      expect(valid_eight_mm).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_eight_mm).not_to be_valid
    end
  end

  describe "has validated fields:" do
    [:pack_deformation, :recording_standard, :image_format, :format_version, :playback_speed, :binder_system].each do |field|
      specify "#{field} value in list" do
        valid_eight_mm.send(field.to_s + "=", "invalid value")
        expect(valid_eight_mm).not_to be_valid
      end
    end
  end

  describe "has virtual fields:" do
    specify "#damage for pack_deformation" do
      expect(valid_eight_mm.damage).to eq valid_eight_mm.pack_deformation
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_eight_mm.manifest_headers).to eq ["Recording standard", "Format duration", "Tape stock brand", "Image format", "Format version", "Playback speed", "Binder system"]
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryGirl.build(:eight_mm_tm, :valid)

  describe "#master_copies" do
    it "returns 1" do
      expect(valid_eight_mm.master_copies).to eq 1
    end
  end

end
