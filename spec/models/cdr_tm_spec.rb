describe CdrTm do

  let(:cdr_tm) {FactoryBot.build :cdr_tm }

  it "gets a valid object from FactoryBot" do
    expect(cdr_tm).to be_valid
  end

  describe "has required fields:" do
    it "damage" do
      cdr_tm.damage = nil
      expect(cdr_tm).not_to be_valid
    end
    it "damage in values list" do
      cdr_tm.damage = "invalid value"
      expect(cdr_tm).not_to be_valid
    end
    it "format_duration" do
      cdr_tm.format_duration = nil
      expect(cdr_tm).not_to be_valid
    end
    it "format_duration in values list" do
      cdr_tm.format_duration = "invalid value"
      expect(cdr_tm).not_to be_valid
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:cdr_tm) 

  describe "#master_copies" do
    it "returns 1" do
      expect(cdr_tm.master_copies).to eq 1
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(cdr_tm.manifest_headers).to eq []
    end
  end

  describe 'digital provenance requirements' do
    specify 'have customized list' do      
      expect(described_class::DIGITAL_PROVENANCE_FILES).to eq ['Digital Master', 'PresInt']
    end
  end
end

