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
      it "assigns @physical_object to a new formatless object" do
        expect(assigns(:physical_object)).to be_a_new PhysicalObject
        expect(assigns(:physical_object).format).to be_blank
      end
      it "assigns @tm to nil" do
        expect(assigns(:tm)).to be_nil
      end
      it "assigns @dp" do
        expect(assigns(:dp)).to be_a_new DigitalProvenance
      end
      { display_assigned: false,
        edit_mode: true,
        search_mode: true,
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
    pending "test search limit?"
    let!(:picklist) { FactoryGirl.create :picklist }
    let!(:attributes_1) { { title: "TITLE", has_ephemera: true, generation: "Unknown", picklist: nil } }
    let!(:attributes_2) { { title: "TITLE 2", has_ephemera: nil, generation: "", picklist: picklist } }
    let!(:cdr_1) { FactoryGirl.create :physical_object, :cdr, **attributes_1 }
    let!(:cdr_2) { FactoryGirl.create :physical_object, :cdr, **attributes_2 }
    let!(:betacam_1) { FactoryGirl.create :physical_object, :betacam, **attributes_1 }
    let!(:betacam_2) { FactoryGirl.create :physical_object, :betacam, **attributes_2 }
    let(:omit_picklisted) { nil }
    let(:po_terms) { {format: ""} }
    let(:tm_terms) { {fungus: ""} }
    let(:items_all) { [cdr_1, cdr_2, betacam_1, betacam_2] }
    let(:items_1) { [cdr_1, betacam_1] }
    let(:items_2) { [cdr_2, betacam_2] }
    shared_examples "returns item set" do |items_description|
      specify "returns #{items_description}"  do
        expect(assigns(:physical_objects).size).to eq returned.size
        expect(assigns(:physical_objects)).to match_array returned
      end
    end
    context "searching physical object, only" do
      before(:each) { post :advanced_search, omit_picklisted: omit_picklisted, physical_object: po_terms }
      context "with no po terms" do
        context "with omit_picklisted = true" do
          let(:omit_picklisted) { 'true' }
          let(:returned) { items_1 }
          include_examples "returns item set", "items not on picklist"
        end
        context "with omit_picklisted = false" do
          let(:omit_picklisted) { 'false' }
          let(:returned) { items_all }
          include_examples "returns item set", "all items"
        end
      end
      context "with a Boolean term" do
        context "set to true" do
          let(:po_terms) { {has_ephemera: true} }
          let(:returned) { items_1 }
          include_examples "returns item set", "true items"
        end
        context "set to false" do
          let(:po_terms) { {has_ephemera: false} }
          let(:returned) { items_2 }
          include_examples "returns item set", "false/nil items"
        end
      end
      context "with a multi-select term" do
        context "set to one value (withi initial dummy value)" do
          let(:po_terms) { {generation: ["", "Unknown"]} }
          let(:returned) { items_1 }
          include_examples "returns item set", "matching items"
        end
        context "set to one value" do
          let(:po_terms) { {generation: ["Unknown"]} }
          let(:returned) { items_1 }
          include_examples "returns item set", "matching items"
        end
        context "set to multiple values" do
          let(:po_terms) { {generation: ["Unknown", ""]} }
          let(:returned) { items_all }
          include_examples "returns item set", "all items"
        end
      end
      context "with a text term" do
        context "for an exact match" do
          let(:po_terms) { {title: "TITLE"} }
          let(:returned) { items_1 }
          include_examples "returns item set", "exactly matching items"
        end
        context "for a wildcard match" do
          let(:po_terms) { {title: "TITLE*"} }
          let(:returned) { items_all }
          include_examples "returns item set", "wildly matching items"
        end
      end
    end
    context "searching technical metadata" do
      before(:each) do
        cdr_1.ensure_tm.fungus = true
        cdr_1.ensure_tm.save!
      end
      before(:each) { post :advanced_search, omit_picklisted: omit_picklisted, physical_object: po_terms, tm: tm_terms }
      describe "applies tm search terms" do
        let(:po_terms) { {format: "CD-R"} }
        let(:tm_terms) { {fungus: true} }
        let(:returned) { [cdr_1] }
        include_examples "returns item set", "matching items"
      end
    end
  end

end
