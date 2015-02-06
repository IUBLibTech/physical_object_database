describe ResponsesController do
  render_views
  # responses controller does not require CAS
  before(:each) { sign_out }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }
  let(:barcoded_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }

  describe "#metadata" do
    context "with a valid barcode" do
      before(:each) { get :metadata, barcode: barcoded_object.mdpi_barcode }
      it "assigns @physical_object" do
        expect(assigns(:physical_object)).to eq barcoded_object
      end
      it "returns found=true XML" do
        expect(response.body).to match /<found.*true<\/found>/
      end
    end
    shared_examples "finds no object" do
      it "assigns @physical_object to nil" do
        expect(assigns(:physical_object)).to be_nil
      end
      it "returns found=false" do
        expect(response.body).to match /<found.*false<\/found>/
      end
    end
    context "with a 0 barcode" do
      before(:each) { get :metadata, barcode: physical_object.mdpi_barcode }
      include_examples "finds no object"
    end
    context "with an unmatched barcode" do
      before(:each) { get :metadata, barcode: 1234 }
      include_examples "finds no object"
    end
  end

end
