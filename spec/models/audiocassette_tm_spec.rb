describe AudiocassetteTm do

  let(:audiocassette_tm) { FactoryBot.build :audiocassette_tm }

  it 'gets a valid object from FactoryBot' do
    expect(audiocassette_tm).to be_valid
  end

  describe 'has required fields:' do
    [:cassette_type, :sound_field, :noise_reduction, :format_duration, :pack_deformation].each do |required_field|
      specify required_field.to_s do
        audiocassette_tm.send("#{required_field}=", nil)
        expect(audiocassette_tm).not_to be_valid
      end
    end
    describe 'tape_type' do
      ['Mini', 'Micro'].each do |format|
        specify "optional for #{format} type" do
          audiocassette_tm.cassette_type = format
          audiocassette_tm.tape_type = ''
          expect(audiocassette_tm).to be_valid
        end
      end
      specify 'required for Compact type' do
        audiocassette_tm.cassette_type = 'Compact'
        audiocassette_tm.tape_type = ''
        expect(audiocassette_tm).not_to be_valid
      end
    end
    describe '(at least one playback speed)' do
      before(:each) do
        AudiocassetteTm::PLAYBACK_SPEED_FIELDS.each do |f|
          audiocassette_tm.send("#{f}=", false)
        end
      end
      specify '(invalid if all false)' do
        expect(audiocassette_tm).not_to be_valid
      end
      AudiocassetteTm::PLAYBACK_SPEED_FIELDS.each do |f|
        specify "#{f} suffices" do
          audiocassette_tm.send("#{f}=", true)
          expect(audiocassette_tm).to be_valid
        end
      end
    end
  end
  describe 'has optional fields:' do
    [:tape_stock_brand, :damaged_tape, :damaged_shell, :fungus, :other_contaminants, :soft_binder_syndrome].each do |required_field|
      specify required_field.to_s do
        audiocassette_tm.send("#{required_field}=", nil)
        expect(audiocassette_tm).to be_valid
      end
    end
  end

  it_behaves_like 'includes TechnicalMetadatumModule', FactoryBot.build(:audiocassette_tm)

  describe "#master_copies" do
    it "returns 2" do
      expect(audiocassette_tm.master_copies).to eq 2
    end
  end

  describe 'manifest export' do
    specify 'has desired headers' do
      expect(audiocassette_tm.manifest_headers).to eq ['Cassette type', 'Tape type', 'Sound field', 'Tape stock brand', 'Noise reduction', 'Format duration', 'Structural damage', 'Playback speed']
    end
  end

end
