describe DigitalProvenanceController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:physical_object) { FactoryBot.create :physical_object, :cdr, :barcoded }
  let(:cylinder_object) { FactoryBot.create :physical_object, :cylinder, :barcoded }
  let(:valid_dp) { FactoryBot.build :digital_provenance }
  let(:invalid_dp) { FactoryBot.build :digital_provenance, :invalid }

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
    it 'assigns @hide_dp_na' do
      expect(assigns(:hide_dp_na)).to eq true
    end
    it "renders :show" do
      expect(response).to render_template :show
    end
    pending "calls set_nexts"
  end

  describe "GET edit" do
    context 'for a non-cylinder' do
      before(:each) { get :edit, id: physical_object.id }
      include_examples "assigns objects"
      it "assigns @edit_mode" do
        expect(assigns(:edit_mode)).to eq true
      end
      it 'assigns @hide_dp_na' do
        expect(assigns(:hide_dp_na)).to eq true
      end
      it 'renders :edit' do
        expect(response).to render_template :edit
      end
    end
    context 'for a Cylinder' do
      context 'with no digital file provenances' do
        it 'redirects' do
          get :edit, id: cylinder_object.id
          expect(response).to redirect_to dfp_preload_edit_physical_object_path(cylinder_object)
        end
      end
      context 'with digital file provenances' do
        let!(:dfp) { FactoryBot.create(:digital_file_provenance, digital_provenance: cylinder_object.digital_provenance) }
        it 'renders :edit' do
          get :edit, id: cylinder_object.id
          expect(response).to render_template :edit
        end
      end
    end
    pending 'calls set_nexts'
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
    context "with incomplete digital_file_provenance" do
      before(:each) do
        dfp = physical_object.digital_provenance.digital_file_provenances.new(filename: "MDPI_#{physical_object.mdpi_barcode}_01_pres.wav")
        dfp.save!
      end
      before(:each) { patch :update, id: physical_object.id, digital_provenance: { duration: new_duration, digital_file_provenances_attributes: { "1" => physical_object.digital_provenance.digital_file_provenances.first.attributes  } } }
      it "updates attributes" do
        expect(physical_object.digital_provenance.duration).to eq original_duration
        physical_object.digital_provenance.reload
        expect(physical_object.digital_provenance.duration).not_to eq original_duration
      end
      it "flashes incomplete warning" do
        expect(flash[:warning]).to match /complete/
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
      it 'assigns @hide_dp_na' do
        expect(assigns(:hide_dp_na)).to eq true
      end
      it "re-renders edit action" do
        expect(response).to render_template :edit
      end
    end
  end
end
