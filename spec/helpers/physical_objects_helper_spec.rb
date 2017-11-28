describe PhysicalObjectsHelper do
  pending "#invalid_csv_headers"
  pending "#parse_csv"
  describe '.group_key_for_filmdb_title' do
    let(:title_id) { 123 }
    context 'with an existing group key' do
      let!(:existing_group_key) { FactoryBot.create :group_key, filmdb_title_id: title_id }
      it 'returns the exiting group key' do
        expect(PhysicalObjectsHelper.group_key_for_filmdb_title(title_id)).to eq existing_group_key
      end
    end
    context 'without an existing group key' do
      it 'creates a new group key' do
        expect {PhysicalObjectsHelper.group_key_for_filmdb_title(title_id)}.to change(GroupKey, :count).by(1)
      end
    end
  end
end
