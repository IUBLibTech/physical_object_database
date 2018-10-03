describe TechnicalMetadatumModule do
  describe "::format_auto_accept_days(format)" do
    it "returns 40 for audio" do
      expect(TechnicalMetadatumModule.format_auto_accept_days("CD-R")).to eq 40
    end
    it "returns 30 for video" do
      expect(TechnicalMetadatumModule.format_auto_accept_days("U-matic")).to eq 30
    end
    it "returns 30 for film" do
      expect(TechnicalMetadatumModule.format_auto_accept_days("Film")).to eq 30
    end
  end
  describe '.tm_digital_provenance_files' do
    it 'returns a Hash' do
      expect(described_class.tm_digital_provenance_files).to be_a Hash
    end
    it 'has a value for each format' do
      expect(described_class.tm_digital_provenance_files.keys.sort).to eq described_class.tm_formats_array.sort
    end
  end
end
