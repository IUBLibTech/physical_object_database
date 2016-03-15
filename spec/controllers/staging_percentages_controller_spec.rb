describe StagingPercentagesController do
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
  let(:valid_sp) { FactoryGirl.create :staging_percent }
  let(:invalid_sp) { FactoryGirl.create :staging_percent, :invalid }
  let(:percentage) { FactoryGirl.create :staging_percent }

  describe "GET index" do
    before(:each) { get :index }
    it 'assigns @percentages' do
      expect(assigns(:percentages)).not_to be_empty
    end
    it 'renders :index template' do
      expect(response).to render_template :index
    end
  end

  describe "PUT update" do
    before(:each) { percentage }
    let(:update) { put :update, id: percentage.id, staging_percentage: valid_sp.attributes.symbolize_keys.merge(memnon_percent: updated_percent) }
    context "with valid params" do
      let(:updated_percent) { 42 }
      it "updates the object" do
        expect(percentage.memnon_percent).not_to eq updated_percent
        update
        percentage.reload
        expect(percentage.memnon_percent).to eq updated_percent
      end
      it "flashes success notice" do
        update
        expect(flash.now[:notice]).to match /updated/
      end
      it "render :index" do
        update
        expect(response).to render_template :index
      end
    end
    context "with invalid params" do
      let(:updated_percent) { -42 }
      it "does not update the object" do
        expect(percentage.memnon_percent).not_to eq updated_percent
        update
        percentage.reload
        expect(percentage.memnon_percent).not_to eq updated_percent
      end
      it "flashes a warning" do
        update
        expect(flash.now[:warning]).to match /not.*saved/i
      end
      it "renders :index" do
        update
        expect(response).to render_template :index
      end
    end
  end

  describe "::validate_formats" do
    it "populates staging_percentages table" do
      expect(StagingPercentage.all).to be_empty
      StagingPercentagesController.validate_formats
      expect(StagingPercentage.all).not_to be_empty
      expect(StagingPercentage.all.size).to eq TechnicalMetadatumModule.tm_formats_array.size
    end
  end

end
