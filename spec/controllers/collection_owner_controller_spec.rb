describe CollectionOwnerController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  describe "#index" do
    pending "write index tests"
  end

  describe "#show" do
    let(:good) { FactoryGirl.create( :physical_object, :cdr, mdpi_barcode: valid_mdpi_barcode, unit: Unit.first ) }
    let(:bad) { FactoryGirl.create( :physical_object, :cdr, mdpi_barcode: valid_mdpi_barcode, unit: Unit.last ) }

    # make sure the web_admin user (what rspec uses for testing) is properly unit affiliated
    before(:each) {
      User.find_by_username('web_admin').update_attributes(unit_id: Unit.first.id)
    }

    it 'allows access to a physical object in a users unit' do
      get :show, id: good.id
      expect(assigns(:physical_object)).to eq good
      expect(response).to render_template(:show)
    end

    it 'does not allow access to a physical object from another unit than the users' do
      get :show, id: bad.id
      expect(assigns(:physical_object)).to eq bad
      expect(response).to redirect_to '/collection_owner'
    end

  end

  describe "#search" do
    pending "write search tests"
  end

end
