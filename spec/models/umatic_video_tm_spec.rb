describe UmaticVideoTm do
  let(:umatic) { FactoryBot.create :umatic_tm, :valid }
  let(:valid_umatic) { FactoryBot.build :umatic_tm, :valid }
  let(:invalid_umatic) { FactoryBot.build :umatic_tm, :invalid }

  describe "FactoryBot" do
    it "provides a valid object" do
      expect(umatic).to be_valid
      expect(valid_umatic).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_umatic).not_to be_valid
    end
  end

  describe "has validated fields:" do
    [:pack_deformation, :recording_standard, :format_duration, :size, :image_format, :format_version ].each do |field|
      specify "#{field} value in list" do
        valid_umatic.send(field.to_s + "=", "invalid value")
        expect(valid_umatic).not_to be_valid
      end
    end
  end

  describe "has default values" do
    specify "recording_standard: NTSC" do
      valid_umatic.recording_standard = nil
      valid_umatic.default_values
      expect(valid_umatic.recording_standard).to eq "NTSC"
    end
    specify "image_format: 4:3" do
      valid_umatic.image_format = nil
      valid_umatic.default_values
      expect(valid_umatic.image_format).to eq "4:3"
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:umatic_tm)

  describe "has virtual fields:" do
    specify "#damage for pack_deformation" do
      expect(valid_umatic.damage).to eq valid_umatic.pack_deformation
    end
    describe "#master copies" do
      it "returns 1" do
        expect(umatic.master_copies).to eq 1
      end
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_umatic.manifest_headers).to eq ["Recording standard", "Format duration", "Size", "Tape stock brand", "Image format", "Format version" ]
    end
  end

end
