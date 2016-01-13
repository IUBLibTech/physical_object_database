describe SearchController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:physical_object) { FactoryGirl.create :physical_object, :boxable, :barcoded, title: "test title", call_number: "test call number" }
  let(:bin) { FactoryGirl.create :bin }
  let(:box) { FactoryGirl.create :box }
  

  describe "GET #index" do
    before(:each) do
      get :index
    end
    describe "assigns variables:" do
      it "assigns @physical_object to a new CD-R object" do
        expect(assigns(:physical_object)).to be_a_new PhysicalObject
        expect(assigns(:physical_object).format).to eq "CD-R"
      end
      it "assigns @tm" do
        expect(assigns(:tm)).to be_a_new CdrTm
      end
      it "assigns @dp" do
        expect(assigns(:dp)).to be_a_new DigitalProvenance
      end
      { display_assigned: true,
        edit_mode: true,
        submit_text: 'Search',
        controller: 'search',
        action: 'advanced_search'
      }.each do |variable, value|
        specify "#{variable.to_s}: #{value}" do
          expect(assigns(variable)).to eq value
        end
      end
    end
    it "renders :index" do
      expect(response).to render_template :index
    end
  end

  describe "GET #search_results" do
    before(:each) do
      physical_object; bin; box
      post :search_results, identifier: term
    end
    context "searching on a blank term" do
      let(:term) { '' }
      it "returns no results" do
        expect(assigns(:physical_objects)).to be_empty
        expect(assigns(:bins)).to be_empty
        expect(assigns(:boxes)).to be_empty
      end
      it "flashes a warning" do
        expect(flash.now[:warning]).to match /no/i
      end
    end
    context "searching on a non-matching term" do
      let(:term) { 'term with no matches' }
      it "returns no results" do
        expect(assigns(:physical_objects)).to be_empty
        expect(assigns(:bins)).to be_empty
        expect(assigns(:boxes)).to be_empty
      end
    end
    context "matching on barcodes" do
      let(:term) { '4' }
      it "returns physical objects, bins, and boxes" do
        expect(assigns(:physical_objects)).to include physical_object
        expect(assigns(:bins)).to include bin
        expect(assigns(:boxes)).to include box
      end
    end
    context "matching on title" do
      let(:term) { 'title' }
      it "returns matching physical objects, only" do
        expect(assigns(:physical_objects)).to include physical_object
        expect(assigns(:bins)).to be_empty
        expect(assigns(:boxes)).to be_empty
      end
    end
    context "matching on call number" do
      let(:term) { 'call' }
      it "returns matching physical objects, only" do
        expect(assigns(:physical_objects)).to include physical_object
        expect(assigns(:bins)).to be_empty
        expect(assigns(:boxes)).to be_empty
      end
    end
    context "matching on bin identifier" do
      let(:term) { 'Test Bin' }
      it "returns the matching bin, only" do
        expect(assigns(:physical_objects)).to be_empty
        expect(assigns(:bins)).to include bin
        expect(assigns(:boxes)).to be_empty
      end
    end
  end

  describe "GET #advanced_search" do
    skip "WRITE TESTS"
  end

end
