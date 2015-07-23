#
# requires let statements for:
# test_object
#
shared_examples "ensure_tm examples" do 

  describe "#ensure_tm" do
    let(:original_tm) { test_object.technical_metadatum.as_technical_metadatum }
    specify "returns nil for an invalid format" do
      test_object.format = "invalid"
      expect(test_object.ensure_tm).to eq nil
    end
    specify "returns existing tm if valid and matching" do
      original_tm
      new_tm = test_object.ensure_tm
      expect(new_tm).to equal original_tm
    end
    specify "returns a new tm if missing" do
      original_tm
      test_object.technical_metadatum = nil
      new_tm = test_object.ensure_tm
      expect(new_tm).to be_a_new TechnicalMetadatum
      expect(new_tm).not_to equal original_tm
    end
    specify "generates a valid tm" do
      test_object.technical_metadatum = nil
      test_object.ensure_tm
      expect(test_object.technical_metadatum).to be_valid
      expect(test_object.technical_metadatum.as_technical_metadatum).to be_valid
    end
    context "if format changes" do
      before(:each) do
        expect(test_object.format).to eq "CD-R"
	test_object.format = "DAT"
      end
      specify "returns a new tm" do
        original_tm
        new_tm = test_object.ensure_tm
        expect(new_tm).to be_a_new TechnicalMetadatum
        expect(new_tm).not_to eq original_tm
      end
      specify "does not destroy the old tm before save" do
        expect{ test_object.ensure_tm }.not_to change(TechnicalMetadatum, :count)
      end
    end
  end

end

