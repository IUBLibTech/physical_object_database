describe QualityControlController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let!(:po) { FactoryGirl.create :physical_object, :open_reel, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }
  let!(:po1) { FactoryGirl.create :physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }
  let!(:po2) { FactoryGirl.create :physical_object, :dat, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }
  let!(:po3) { FactoryGirl.create :physical_object, :betacam, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }
  let(:all_objects) { [po, po1, po2, po3] }
  let(:iu_objects) { [po, po1] }
  let(:memnon_objects) { [po2, po3] }

  let(:ds) { FactoryGirl.create :digital_status, :valid, state: "failed" }
  let(:ds1) { FactoryGirl.create :digital_status, :valid, state: "accepted" }
  let(:ds2) { FactoryGirl.create :digital_status, :valid, state: "transfered" }

  describe "#index" do
    context "with no status filter" do
      before(:each) do
        get :index
      end
      it "does not assign @physical_objects" do
        expect(assigns(:physical_objects)).to be_nil
      end
      it "renders :index" do
        expect(response).to render_template :index
      end
    end
    context "with status filter" do
      before(:each) do
        ds.physical_object_mdpi_barcode = po.mdpi_barcode
        ds.physical_object_id = po.id
        ds.options = { foo: :bar }
        ds.decided = nil
        ds.save!
        get :index, status: ds.state
      end
      it "assigns matching @physical_objects" do
        expect(assigns(:physical_objects)).to eq [po]
      end
      it "renders :index" do
        expect(response).to render_template :index
      end
    end
  end

  describe "#decide" do
    context "making a decision" do
      before(:each) {
        ds.physical_object_mdpi_barcode = po.mdpi_barcode
        ds.physical_object_id = po.id
        ds.save!
        patch :decide, id: ds.id, decided: ds.options[ds.options.keys[2]]
        expect(assigns(:ds)).not_to be_nil
        ds.reload
      }
      it "sets the decision for a digital status state" do
        expect(ds.decided).to eq ds.options[ds.options.keys[2]]
      end
      it "sets the 'decided_manually' flag" do
        expect(ds.decided_manually).to eq true
      end
    end
  end

  describe "#auto_accept" do
    before(:each) { get :auto_accept }
    after(:each) { DigitalFileAutoAcceptor.instance.stop }
    it "renders the :auto_accept template" do
      expect(response).to render_template :auto_accept
    end
  end

  describe "IU and Memnon staging" do
    let(:current_date) { Time.new(Time.now.year, Time.now.month, Time.now.day) }
    let(:past_date) { Time.new(Time.now.year - 1, Time.now.month, Time.now.day) }
    let(:date) { current_date }
    let(:date_text) { date.strftime('%m/%d/%Y') }
    let(:results) { [] }
    let(:formats) { results.map { |o| o.format } }
    let(:results_hash) do
      h = {}
      formats.uniq.each do |format|
        h[format] = results.select { |o| o.format == format }
      end
      h
    end
    before(:each) do 
      [iu_objects, memnon_objects].each do |object_array|
        object_array.first.digital_start = past_date
        object_array.first.save!
        object_array.last.digital_start = current_date
        object_array.last.save!
      end

      iu_objects.each do |object|
        object.digital_provenance.digitizing_entity = DigitalProvenance::IU_DIGITIZING_ENTITY
        object.digital_provenance.save!
      end
      memnon_objects.each do |object|
        object.digital_provenance.digitizing_entity = DigitalProvenance::MEMNON_DIGITIZING_ENTITY
        object.digital_provenance.save!
      end
    end
    shared_examples "staging examples" do |staging_index, entity|
      it "assigns @action to #{staging_index}" do
        expect(assigns(:action)).to eq staging_index.to_s
      end
      it "assigns @date to date" do
        expect(assigns(:date)).to eq DateTime.strptime(date_text, '%m/%d/%Y')
      end
      it "assigns @d_entity to #{entity}" do
        expect(assigns(:d_entity)).to eq entity
      end
      it "assigns @formats to unstaged formats for that date" do
        expect(assigns(:formats)).to eq formats
      end
      it "assigns @format_to_physical_objects to matching objects" do
        expect(assigns(:format_to_physical_objects)).to eq results_hash
      end
      it "renders 'staging'" do
        expect(response).to render_template :staging
      end
    end
    shared_examples "staging contexts" do |staging_action, entity|
      context "with no params" do
        # second object only -- matches current_date
        let(:results) { [objects.last] }
        before(:each) { get staging_action }
        include_examples "staging examples", staging_action, entity
      end
      context "setting a date" do
        let(:date) { past_date }
        let(:date_text) { date.strftime('%m/%d/%Y') }
        # first object only -- matches past_date
        let(:results) { [objects.first] }
        before(:each) { get staging_action, staging: { date: date_text } }
        include_examples "staging examples", staging_action, entity
      end
      context "setting a format" do
        let(:format) { objects.last.format }
        let(:results) { [objects.last] }
        # set all objects to current_date to test format filtering
        before(:each) do
          objects.each do |object|
            object.digital_start = current_date
            object.save!
          end
        end
        before(:each) { get staging_action, staging: { format: format } }
        include_examples "staging examples", staging_action, entity
      end
    end
    context "IU staging" do
      let(:objects) { iu_objects }
      include_examples "staging contexts", :iu_staging_index, "IU"
    end
    context "Memnon staging" do
      let(:objects) { memnon_objects }
      include_examples "staging contexts", :staging_index, "Memnon"
    end
  end
  describe "#staging_post" do
    context "passing valid selections" do
      before(:each) { post :staging_post, commit: 'Stage Selected Objects', selected: iu_objects.map { |o| o.id } }
      it "updates staging_requested" do
        iu_objects.each do |object|
          expect(object.staging_requested).to eq false
          object.reload
          expect(object.staging_requested).to eq true
        end
      end
      it "updates staging_request_timestamp" do
        iu_objects.each do |object|
          expect(object.staging_request_timestamp).to be_nil
          object.reload
          expect(object.staging_request_timestamp).not_to be_nil
        end
      end
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
      end
    end
  end
  describe "#stage" do #Q: update staging_request_timestamp?
    before(:each) { post :stage, id: id }
    context "passing a valid id" do
      let(:id) { po.id }
      it "assigns success status" do
        expect(assigns(:success)).to eq true
      end
      it "assigns success message" do
        expect(assigns(:msg)).to match /success/
      end
      it "updates staging_requested" do
        expect(po.staging_requested).to eq false
        po.reload
        expect(po.staging_requested).to eq true
      end
      it "updates staging_request_timestamp" do
        expect(po.staging_request_timestamp).to be_nil
        po.reload
        expect(po.staging_request_timestamp).not_to be_nil
      end
    end
    context "passing an invalid id" do
      let(:id) { 'invalid_id' }
      it "assigns failure status" do
        expect(assigns(:success)).to eq false
      end
      it "assigns failure message" do
        expect(assigns(:msg)).to match /ERROR/
      end
    end
  end

  
end
