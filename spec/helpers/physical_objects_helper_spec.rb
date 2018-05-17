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
  describe '.parse_xml' do
    let(:xml) { File.read(Rails.root.join('spec', 'fixtures', 'filmdb.xml')) }
    let(:parse_action) { PhysicalObjectsHelper.parse_xml(xml, convert_only: convert_only) }
    context 'in ingest mode' do
      let(:convert_only) { false }
      it 'ingests' do
        expect { parse_action }.to change(PhysicalObject, :count)
      end
      it 'does not persist the tempfile' do
        expect_any_instance_of(Tempfile).to receive(:unlink)
        parse_action
      end
    end
    context 'in conversion mode' do
      let(:convert_only) { true }
      it 'does not ingest' do
        expect { parse_action }.not_to change(PhysicalObject, :count)
      end
      it 'persists the tempfile' do
        expect_any_instance_of(Tempfile).not_to receive(:unlink)
        parse_action
      end
    end
  end
end
