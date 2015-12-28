describe DigitalProvenanceController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }
  let(:valid_dp) { FactoryGirl.build :digital_provenance }
  let(:invalid_dp) { FactoryGirl.build :digital_provenance, :invalid }

  shared_examples "assigns objects" do
    it "assigns physical object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
    it "assigns tm" do
      expect(assigns(:tm)).to eq physical_object.technical_metadatum.specific
    end
    it "assigns dp" do
      expect(assigns(:dp)).to eq physical_object.digital_provenance
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: physical_object.id }
    include_examples "assigns objects"
    it "renders :show" do
      expect(response).to render_template :show
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: physical_object.id }
    include_examples "assigns objects"
    it "assigns @edit_mode" do
      expect(assigns(:edit_mode)).to eq true
    end
    it "renders :show" do
      expect(response).to render_template :edit
    end
  end

  describe "PATCH update" do
    let!(:original_duration) { physical_object.digital_provenance.duration }
    let!(:new_duration) { original_duration.to_i + 100 }
    context "with valid attributes" do
      before(:each) { patch :update, id: physical_object.id, digital_provenance: { duration: new_duration } }
      it "updates attributes" do
        expect(physical_object.digital_provenance.duration).to eq original_duration
        physical_object.digital_provenance.reload
        expect(physical_object.digital_provenance.duration).not_to eq original_duration
      end
      it "redirects to show" do
        expect(response).to redirect_to controller: :digital_provenance, id: physical_object.id, action: :show
      end
    end
    # invalid by means of invalid digital_file_provenance
    context "with invalid attributes" do
      before(:each) { patch :update, id: physical_object.id, digital_provenance: { digital_file_provenances_attributes: { "1" => {} } } }
      it "assigns @edit_mode" do
        expect(assigns(:edit_mode)).to eq true
      end
      it "re-renders edit action" do
        expect(response).to render_template :edit
      end
    end
  end
end
