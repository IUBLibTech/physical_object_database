describe SearchController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:physical_object) { FactoryBot.create :physical_object, :boxable, :barcoded, title: "test title", call_number: "test call number" }
  let(:bin) { FactoryBot.create :bin }
  let(:box) { FactoryBot.create :box }
  

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
    let!(:picklist) { FactoryBot.create :picklist }
    let!(:attributes_1) { { title: "TITLE", has_ephemera: true, generation: "Unknown", picklist: nil } }
    let!(:attributes_2) { { title: "TITLE 2", has_ephemera: nil, generation: "", picklist: picklist } }
    let!(:cdr_1) { FactoryBot.create :physical_object, :cdr, :barcoded, unit: Unit.all[0], **attributes_1 }
    let!(:cdr_2) { FactoryBot.create :physical_object, :cdr, mdpi_barcode: 0, unit: Unit.all[1], **attributes_2 }
    let!(:betacam_1) { FactoryBot.create :physical_object, :betacam, :barcoded, unit: Unit.all[2], **attributes_1 }
    let!(:betacam_2) { FactoryBot.create :physical_object, :betacam, mdpi_barcode: 0, unit: Unit.all[3], **attributes_2 }
    let(:mdpi_barcode_category) { nil } 
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
    context "with XLS results" do
      before(:each) { post :advanced_search,
                      mdpi_barcode_category: mdpi_barcode_category,
                      omit_picklisted: omit_picklisted,
                      physical_object: po_terms, 
                      format: "xls" }
      context "without specifying a format" do
        it "assigns @block_metadata = true" do
          expect(assigns(:block_metadata)).to eq true
        end
        it "render XLS results" do
          expect(response).to render_template 'search/show'
        end
      end
      context "specifying a format" do
        let(:po_terms) { {format: "CD-R"} }
        it "does not @block_metadata" do
          expect(assigns(:block_metadata)).not_to eq true
        end
        it "render XLS results" do
          expect(response).to render_template 'search/show'
        end
      end
    end
    context "searching physical object, only" do
      before(:each) { post :advanced_search,
                      mdpi_barcode_category: mdpi_barcode_category,
                      omit_picklisted: omit_picklisted,
                      physical_object: po_terms }
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
        context "set to one value (with initial dummy value)" do
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
      context "with an association term" do
        before(:each) do
          (0..3).each do |i|
             items_all[i].unit = Unit.all[i]
             items_all[i].save!
          end
        end
        context "set to one value (with initial dummy value)" do
          let(:po_terms) { {unit_id: ["", items_all[0].unit_id]} }
          let(:returned) { [items_all[0]] }
          include_examples "returns item set", "matching item"
        end
        context "set to one value" do
          let(:po_terms) { {unit_id: [items_all[0].unit_id]} }
          let(:returned) { [items_all[0]] }
          include_examples "returns item set", "matching item"
        end
        context "set to multiple values" do
          let(:po_terms) { {unit_id: [items_1[0].unit_id, items_1[1].unit_id]} }
          let(:returned) { items_1 }
          include_examples "returns item set", "matching items"
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
        context "with an injection attempt" do
          let(:po_terms) { {title: "unused*' OR 1=1); -- "} }
          let(:returned) { PhysicalObject.none }
          include_examples "returns item set", "(no items)"
        end
      end
      context "with a barcode category" do
        context "for real barcodes" do
          let(:mdpi_barcode_category) { 'real' }
          let(:returned) { items_1 }
          include_examples "returns item set", "barcoded items"
        end
        context "for zero barcodes" do
          let(:mdpi_barcode_category) { 'zero' }
          let(:returned) { items_2 }
          include_examples "returns item set", "barcoded items"
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
    context "searching condition_status" do
      before(:each) do
        items_1.each do |item|
          cs = item.condition_statuses.new(active: true, condition_status_template_id: ConditionStatusTemplate.first.id)
          cs.save!
        end
      end
      before(:each) { post :advanced_search, omit_picklisted: omit_picklisted, physical_object: po_terms, tm: tm_terms, condition_status: cs_terms }
      describe "applies condition_status search terms" do
        let(:po_terms) { { title: ""} }
        let(:tm_terms) { {} }
        let(:cs_terms) { {active: true, condition_status_template_id: [ConditionStatusTemplate.first.id]} }
        let(:returned) { items_1 }
        include_examples "returns item set", "matching items"
      end
    end
    context "searching notes" do
      before(:each) do
        items_1.each do |item|
          note = item.notes.new(body: 'note test')
          note.save!
        end
      end
      before(:each) { post :advanced_search, omit_picklisted: omit_picklisted, physical_object: po_terms, tm: tm_terms, note: note_terms }
      describe "applies note search terms" do
        let(:po_terms) { { title: ""} }
        let(:tm_terms) { {} }
        let(:note_terms) { {body: '*test*'} }
        let(:returned) { items_1 }
        include_examples "returns item set", "matching items"
      end
    end
    context "searching workflow history" do
      before(:each) do
        items_2.each do |item|
          item.workflow_statuses.each do |ws|
            ws.update_attributes!(created_at: Time.new(4001, 2, 3), updated_at: Time.new(4001, 2, 3))
          end
        end
      end
      before(:each) { post :advanced_search, omit_picklisted: omit_picklisted, physical_object: po_terms, tm: tm_terms, workflow_status: ws_terms }
      describe "applies workflow status search terms" do
        let(:po_terms) { { title: ""} }
        let(:tm_terms) { {} }
        let(:start_date) { Time.new(2001, 2, 3) }
        let(:end_date) { Time.new(3001, 2, 3) }
        let(:ws_terms) { {workflow_status_template_id: WorkflowStatusTemplate.all.map { |t| t.id }, created_at: start_date, updated_at: end_date} }
        let(:returned) { items_1 }
        include_examples "returns item set", "matching items"
      end
    end
  end

end
