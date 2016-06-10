describe BoxesController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:batch) { FactoryGirl.create(:batch) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:other_bin) { FactoryGirl.create(:bin, identifier: "other " + bin.identifier) }
  let(:box) { FactoryGirl.create(:box) }
  let(:binned_box) { FactoryGirl.create(:box, bin: bin) }
  let(:boxed_object) { FactoryGirl.create(:physical_object, :cdr, :barcoded, box: box) }
  let(:binned_object) { FactoryGirl.create(:physical_object, :cdr, :barcoded, bin: bin) }
  let(:picklist) { FactoryGirl.create(:picklist) }
  let!(:complete) {FactoryGirl.create(:picklist, name: 'complete', complete: true)}
  let(:spreadsheet) { FactoryGirl.create(:spreadsheet) }
  let(:valid_box) { FactoryGirl.build(:box) }
  let(:invalid_box) { FactoryGirl.build(:invalid_box) }

  describe "GET index" do
    context "specifying a bin" do
      before(:each) do
        bin.save
        binned_box.save
        box.save
        get :index, bin_id: bin.id, format: format
      end
      shared_examples "index behaviors" do
        it "assigns @bin" do
          expect(assigns(:bin)).to eq bin
        end
        it "populates boxes in that bin" do
          expect(assigns(:boxes)).to eq [binned_box]
        end
        it "renders the :index view" do
          expect(response).to render_template(:index)
        end
      end
      context "html format" do
        let(:format) { :html }
        include_examples "index behaviors"
      end
      context "xls format" do
        let(:format) { :xls }
        include_examples "index behaviors"
      end
    end
    context "without specifying a bin" do
      let(:format1) { TechnicalMetadatumModule.box_formats.first }
      let(:format2) { TechnicalMetadatumModule.box_formats.last }
      let!(:box1) { FactoryGirl.create(:box, format: format1, description: 'box1', bin: bin) }
      let!(:box2) { FactoryGirl.create(:box, format: format2, description: 'box2') }
      before(:each) do
        get :index, format: format, assignment: assignment, tm_format: tm_format, description: description
      end
      context "with no filters" do
        let(:format) { :html }
        let(:assignment) { nil }
        let(:tm_format) { nil }
        let(:description) { nil }
        it "assigns @boxes empty" do
          expect(assigns(:boxes)).to be_empty
        end
        it 'renders :index' do
          expect(response).to render_template :index
        end
      end
      context "with empty filters" do
        let(:assignment) { '' }
        let(:tm_format) { '' }
        let(:description) { '' }
        shared_examples "all results" do
          it "assigns @boxes to all" do
            expect(assigns(:boxes).sort).to match Box.all
          end
          it 'renders :index' do
            expect(response).to render_template :index
          end
        end
        [:html, :xls].each do |get_format|
          context "#{get_format} format" do
            let(:format) { get_format }
            include_examples "all results"
          end
        end
      end
      context "with format filter" do
        let(:format) { :html }
        let(:assignment) { '' }
        let(:tm_format) { format1 }
        let(:description) { '' }
        it "assigns @boxes to matching formats" do
          expect(assigns(:boxes).sort).to match [box1]
        end
        it 'renders :index' do
          expect(response).to render_template :index
        end
      end
      context "with description filter" do
        let(:format) { :html }
        let(:assignment) { '' }
        let(:tm_format) { '' }
        let(:description) { '1' }
        it "assigns @boxes to matching descriptions" do
          expect(assigns(:boxes).sort).to match [box1]
        end
        it 'renders :index' do
          expect(response).to render_template :index
        end
      end
      context 'with assignment filter' do
        let(:format) { :html }
        let(:tm_format) { '' }
        let(:description) { '' }
        context 'set to "all"' do
          let(:assignment) { 'all' }
          it "assigns @boxes to all boxes" do
            expect(assigns(:boxes).sort).to match [box1, box2].sort
          end
          it 'renders :index' do
            expect(response).to render_template :index
          end
        end
        context 'set to "assigned"' do
          let(:assignment) { 'assigned' }
          it "assigns @boxes to binned boxes" do
            expect(assigns(:boxes)).to match [box1]
          end
          it 'renders :index' do
            expect(response).to render_template :index
          end
        end
        context 'set to "assigned"' do
          let(:assignment) { 'unassigned' }
          it "assigns @boxes to unbinned boxes" do
            expect(assigns(:boxes)).to match [box2]
          end
          it 'renders :index' do
            expect(response).to render_template :index
          end
        end
      end
    end
  end

  describe "GET show" do
    before(:each) do
      picklist
      boxed_object
      box
      get :show, id: box.id
    end
    it "assigns the requested object to @box" do
      expect(assigns(:box)).to eq box
    end
    it "assigns boxed @physical_objects" do
      expect(assigns(:physical_objects)).to eq [boxed_object]
    end
    include_examples "provides pagination", :physical_objects
    it "builds @picklist select array" do
      expect(assigns(:picklists)).to eq [[picklist.name,picklist.id]]
    end
    it "renders the :show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET new" do
    context "specifying a bin" do
      before(:each) { get :new, bin_id: bin.id }
      it "assigns @bin" do
        expect(assigns(:bin)).to eq bin
      end
      it "creates a box associated to the bin" do
        expect(assigns(:box).bin).to eq bin
      end
      it "renders the :new template" do
        expect(response).to render_template :new
      end
    end
    context "not specifying a bin" do
      before(:each) { get :new }
      it "creates a box with no bin association" do
        expect(assigns(:box)).to be_a_new Box
      end
      it "renders the :new template" do
        expect(response).to render_template :new
      end
    end
  end

  describe "GET edit" do
    before(:each) do 
      boxed_object
      box
      bin
      get :edit, id: box.id
    end
    it "assigns @box" do
      expect(assigns(:box)).to eq box
    end
    it "assigns @bins" do
      expect(assigns(:bins)).to eq [bin]
    end
    it "assigns @physical_objects" do
      expect(assigns(:physical_objects)).to eq [boxed_object]
    end
    it "renders the edit template" do
      expect(response).to render_template :edit
    end 
  end

  describe "POST create" do
    context "for a bin" do
      let(:creation) { post :create, bin_id: bin.id, box: valid_box.attributes.symbolize_keys }
      it "saves the new object in the database" do
        expect{ creation }.to change(Box, :count).by(1)
      end
      it "assigns the new Box to the specified Bin" do
        creation
        expect(Box.last.bin).to eq bin
      end
      it "redirects to the object" do
        creation
        expect(response).to redirect_to assigns(:box)
      end
    end
    context "with valid attributes" do
      let(:creation) { post :create, box: valid_box.attributes.symbolize_keys }
      it "saves the new object in the database" do
        expect{ creation }.to change(Box, :count).by(1)
      end
      it "redirects to the object" do
        creation
        expect(response).to redirect_to assigns(:box)
      end
    end
    context "with invalid attributes" do
      let(:creation) { post :create, box: invalid_box.attributes.symbolize_keys }
      it "does not save the new object in the database" do
        expect{ creation }.not_to change(Box, :count)
      end
      it "re-renders the :new template" do
        creation
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT update" do
    context "with valid attributes" do
      before(:each) do
        put :update, id: box.id, box: FactoryGirl.attributes_for(:box, spreadsheet_id: spreadsheet.id)
      end
      it "locates the requested object" do
        expect(assigns(:box)).to eq box
      end
      it "changes the object's attributes" do
        expect(box.spreadsheet).to be_nil
        box.reload
        expect(box.spreadsheet).to eq spreadsheet
      end
      it "redirects to the updated object" do
        expect(response).to redirect_to(action: :show) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: box.id, box: FactoryGirl.attributes_for(:invalid_box)
      end
      it "locates the requested object" do
        expect(assigns(:box)).to eq box
      end
      it "does not change the object's attributes" do
        expect(box.mdpi_barcode).not_to be_nil
        box.reload
        expect(box.mdpi_barcode).not_to be_nil
      end
      it "renders the :edit template" do
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: box.id }
    it "deletes the object" do
      box
      expect{ deletion }.to change(Box, :count).by(-1)
    end
    it "redirects to the bins index" do
      deletion
      expect(response).to redirect_to bins_path
    end
    it "disassociates remaining physical objects" do
      boxed_object
      deletion
      boxed_object.reload
      expect(boxed_object.box).to be_nil
    end
    it "resets remaining physical objects workflow status" do
      expect(boxed_object.workflow_status).to eq "Boxed"
      deletion
      boxed_object.reload
      expect(boxed_object.workflow_status).not_to eq "Boxed"
    end
  end

  describe "PUT unbin" do
    context "specifying a bin" do
      context "when binned" do
        before(:each) { put :unbin, id: binned_box.id, bin_id: bin.id }
        it "unbins the box" do
          binned_box.reload
          expect(binned_box.bin).to be_nil
        end
        it "flashes a success notice" do
          expect(flash[:notice]).to match /Success/
        end
        it "redirects to the bin" do
          expect(response).to redirect_to bin
        end
      end
      context "when binned, but in a different bin" do
        before(:each) { put :unbin, id: binned_box, bin_id: other_bin.id }
	it "flashes a different association warning" do
	  expect(flash[:warning]).to match /different/
	end
	it "redirects to the bin" do
	  expect(response).to redirect_to other_bin
	end
      end
      context "when not in a bin" do
        before(:each) { put :unbin, id: box.id, bin_id: bin.id }
        it "flashes a not associated warning" do
          expect(flash[:warning]).to match /not associated/
        end
        it "redirects to the bin" do
          expect(response).to redirect_to bin
        end
      end
    end
    context "not specifying a bin" do
      context "when binned" do
        context "when successful" do
          before(:each) { put :unbin, id: binned_box.id }
          it "unbins the box" do
            binned_box.reload
            expect(binned_box.bin).to be_nil
          end
          it "flashes a success notice" do
            expect(flash[:notice]).to match /Success/
          end
          it "redirects to the box" do
            expect(response).to redirect_to binned_box
          end
        end
        context "when failed" do
          before(:each) do
            binned_box.mdpi_barcode = 42
            binned_box.save!(validate: false)
            put :unbin, id: binned_box.id
          end
          it "does not unbin the box" do
            binned_box.reload
            expect(binned_box.bin).not_to be_nil
          end
          it "flashes a failure warning" do
            expect(flash[:warning]).to match /fail/i
          end
          it "redirects to the box" do
            expect(response).to redirect_to binned_box
          end

        end
      end
      context "when not in a bin" do
        before(:each) { put :unbin, id: box.id }
        it "flashes a not associated warning" do
          expect(flash[:warning]).to match /not associated/
        end
        it "redirects to the box" do
          expect(response).to redirect_to box
        end
      end
    end
  end

end
