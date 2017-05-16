describe TechnicalMetadatumModule do
  describe "::format_auto_accept_days(format)" do
    it "returns 40 for audio" do
      expect(TechnicalMetadatumModule.format_auto_accept_days("CD-R")).to eq 40
    end
    it "returns 30 for video" do
      expect(TechnicalMetadatumModule.format_auto_accept_days("U-matic")).to eq 30
    end
  end
end
