describe MemnonInvoiceSubmission do
  let(:valid_invoice) { FactoryGirl.build :memnon_invoice_submission }

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_invoice).to be_valid
    end
  end

  describe "has optional attributes:" do
    shared_examples "optional attribute" do |attribute|
      specify attribute do
        valid_invoice.send("#{attribute}=", nil)
        expect(valid_invoice).to be_valid
      end
    end
    include_examples "optional attribute", "submission_date"
    include_examples "optional attribute", "successful_validation"
    include_examples "optional attribute", "validation_completion_percent"
    include_examples "optional attribute", "bad_headers"
    include_examples "optional attribute", "other_error"
    include_examples "optional attribute", "problems_by_row"
  end
  describe "has required attributes:" do
    shared_examples "required attribute" do |attribute|
      specify attribute do
        valid_invoice.send("#{attribute}=", nil)
        expect(valid_invoice).not_to be_valid
      end
    end
    include_examples "required attribute", "filename"

  end
end
