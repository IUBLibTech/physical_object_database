describe MagnabeltTm do

  let(:magnabelt_tm) {FactoryBot.build :magnabelt_tm }
  let(:invalid_magnabelt_tm) {FactoryBot.build :magnabelt_tm, :invalid }

  describe 'FactoryBot' do
    it 'returns a valid object' do
      expect(magnabelt_tm).to be_valid
    end
    it 'returns an invalid_object' do
      expect(invalid_magnabelt_tm).to be_invalid
    end
  end

  describe "has required fields:" do
    shared_examples 'required in list' do |field|
      describe field do
        specify "#{field} cannot be nil" do
          magnabelt_tm.send("#{field}=", nil)
          expect(magnabelt_tm).not_to be_valid
        end
        specify "#{field} must be in values list" do
          magnabelt_tm.send("#{field}=", 'invalid value')
          expect(magnabelt_tm).not_to be_valid
        end
      end
    end
    ['size', 'damage'].each do |field|
      include_examples 'required in list', field
    end
  end

  describe 'has optional fields:' do
    shared_examples 'is optional' do |field|
      describe field do
        specify 'can be nil' do
          magnabelt_tm.send("#{field}=", nil)
          expect(magnabelt_tm).to be_valid
        end
      end
    end
    ['stock_brand'].each do |field|
      include_examples 'is optional', field
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:magnabelt_tm) 

  describe "#master_copies" do
    it "returns 1" do
      expect(magnabelt_tm.master_copies).to eq 1
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(magnabelt_tm.manifest_headers).to eq ['Size', 'Stock brand']
    end
  end

  describe 'digital provenance requirements' do
    specify 'have customized list' do      
      expect(described_class::DIGITAL_PROVENANCE_FILES).to eq ['Digital Master', 'PresInt']
    end
  end
end
