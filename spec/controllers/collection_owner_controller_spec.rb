describe CollectionOwnerController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
  let(:unit_good) { Unit.first }
  let(:unit_bad) { Unit.last }
  let(:status_good) { 'Returned to Unit' }
  let(:status_bad) { 'Unassigned' }
  let(:po_good) { FactoryGirl.create( :physical_object, :cdr, mdpi_barcode: valid_mdpi_barcode, unit: unit_good, workflow_status: status_good ) }
  let(:po_bad_unit) { FactoryGirl.create( :physical_object, :cdr, mdpi_barcode: valid_mdpi_barcode, unit: unit_bad, workflow_status: status_good ) }
  let(:po_bad_status) { FactoryGirl.create( :physical_object, :cdr, mdpi_barcode: valid_mdpi_barcode, unit: unit_good, workflow_status: status_bad ) }

  describe "#index" do
    pending "write index tests"
  end

  describe "#show" do
    context "without a unit association" do
      before(:each) { User.find_by_username('web_admin').update_attributes(unit_id: nil) }
      before(:each) { get :show, id: po_good.id }
      it "flashes a warning" do
        expect(flash[:warning]).to match /must have an associated Unit/i
      end
      it "redirects to :index" do
        expect(response).to redirect_to '/collection_owner'
      end
    end
    context "with a unit association" do
      # make sure the web_admin user (what rspec uses for testing) is properly unit affiliated
      before(:each) {
        User.find_by_username('web_admin').update_attributes(unit_id: Unit.first.id)
      }
  
      it 'allows access to a physical object in a users unit' do
        get :show, id: po_good.id
        expect(assigns(:physical_object)).to eq po_good
        expect(response).to render_template(:show)
      end
  
      it 'does not allow access to a physical object with unviewable workflow status' do
        get :show, id: po_bad_status.id
        expect(assigns(:physical_object)).to be_nil
        expect(response).to redirect_to '/collection_owner'
      end
  
      it 'does not allow access to a physical object from another unit than the users' do
        get :show, id: po_bad_unit.id
        expect(assigns(:physical_object)).to be_nil
        expect(response).to redirect_to '/collection_owner'
      end
    end
  end

  describe "#search" do
    pending "write search tests"
  end

end
