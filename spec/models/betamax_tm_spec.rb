describe BetamaxTm do
  let(:betamax) { FactoryBot.create :betamax_tm, :valid }
  let(:valid_betamax) { FactoryBot.build :betamax_tm, :valid }
  let(:invalid_betamax) { FactoryBot.build :betamax_tm, :invalid }

  describe "FactoryBot" do
    it "provides a valid object" do
      expect(betamax).to be_valid
      expect(valid_betamax).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_betamax).not_to be_valid
    end
  end

  describe "has validated fields:" do
    [:format_version, :recording_standard, :oxide, :image_format, :pack_deformation].each do |field|
      specify "#{field} value in list" do
        valid_betamax.send(field.to_s + "=", "invalid value")
        expect(valid_betamax).not_to be_valid
      end
    end
  end

  describe "has required fields:" do
    [:format_duration].each do |field|
      specify field do
        valid_betamax.send(field.to_s + "=", nil)
        expect(valid_betamax).not_to be_valid
      end
    end
  end

  describe "has virtual fields:" do
    specify "#damage for pack_deformation" do
      expect(valid_betamax.damage).to eq valid_betamax.pack_deformation
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(valid_betamax.manifest_headers).to eq []
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:betamax_tm, :valid)

  describe "#master_copies" do
    it "returns 1" do
      expect(valid_betamax.master_copies).to eq 1
    end
  end

end
