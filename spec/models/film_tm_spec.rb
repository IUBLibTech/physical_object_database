describe FilmTm do
  let(:film_tm) { FactoryGirl.create :film_tm }
  let(:valid_film_tm) { FactoryGirl.build :film_tm }
  let(:invalid_film_tm) { FactoryGirl.build :film_tm, :invalid }

  describe 'FactoryGirl' do
    it 'provides a valid object' do
      expect(valid_film_tm).to be_valid
    end
    it 'provides an invalid object' do
      expect(invalid_film_tm).not_to be_valid
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryGirl.build(:film_tm)

  describe "has validated fields:" do
    [:gauge].each do |field|
      specify "#{field} value in list" do
        valid_film_tm.send(field.to_s + "=", "invalid value")
        expect(valid_film_tm).not_to be_valid
      end
    end
  end

  describe "#master_copies" do
    it "returns 1" do
      expect(film_tm.master_copies).to eq 1
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(film_tm.manifest_headers).to eq ['Year', 'Gauge', 'Film generation', 'Footage', 'Base', 'Frame rate', 'Color', 'Aspect ratio', 'Anamorphic', 'Sound', 'Sound format type', 'Sound content type', 'Sound field', 'Clean', 'Resolution', 'Color space', 'Workflow', 'On demand', 'Return on original reel', 'Film condition', 'Mold', 'Shrinkage', 'AD strip', 'Missing footage', 'Track count', 'Format duration', 'Stock', 'Conservation actions - IU', 'Miscellaneous', 'Return to']
    end
  end

end
