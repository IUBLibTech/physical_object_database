describe DigitalFileProvenance do
  let(:new_dfp) { DigitalFileProvenance.new }
  describe "has default values" do
    specify "created_by" do
      expect(new_dfp.created_by).not_to be_blank
    end
    specify "date_digitized" do
      expect(new_dfp.date_digitized).not_to be_nil
    end
  end
end
