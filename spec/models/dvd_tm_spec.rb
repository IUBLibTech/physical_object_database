describe DvdTm do

  let(:dvd_tm) {FactoryBot.build :dvd_tm }
  let(:invalid_dvd_tm) {FactoryBot.build :dvd_tm, :invalid }

  describe 'FactoryBot' do
    it 'returns a valid object' do
      expect(dvd_tm).to be_valid
    end
    it 'returns an invalid_object' do
      expect(invalid_dvd_tm).to be_invalid
    end
  end

  describe "has required fields:" do
    shared_examples 'required in list' do |field|
      describe field do
        specify "#{field} cannot be nil" do
          dvd_tm.send("#{field}=", nil)
          expect(dvd_tm).not_to be_valid
        end
        specify "#{field} must be in values list" do
          dvd_tm.send("#{field}=", 'invalid value')
          expect(dvd_tm).not_to be_valid
        end
      end
    end
    ['recording_standard', 'format_duration', 'image_format', 'dvd_type', 'damage'].each do |field|
      include_examples 'required in list', field
    end
  end

  describe 'has optional fields:' do
    shared_examples 'is optional' do |field|
      describe field do
        specify 'can be nil' do
          dvd_tm.send("#{field}=", nil)
          expect(dvd_tm).to be_valid
        end
      end
    end
    ['stock_brand'].each do |field|
      include_examples 'is optional', field
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryBot.build(:dvd_tm) 

  describe "#master_copies" do
    it "returns 1" do
      expect(dvd_tm.master_copies).to eq 1
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(dvd_tm.manifest_headers).to eq ['Recording standard', 'Format duration', 'Image format', 'DVD type', 'Stock brand']
    end
  end

end

