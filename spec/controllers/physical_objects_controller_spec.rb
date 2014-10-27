require 'rails_helper'

describe PhysicalObjectsController do
  render_views
  before(:each) { sign_in }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr) }
  let(:second_object) { FactoryGirl.create(:physical_object, :cdr, unit: physical_object.unit, group_key: physical_object.group_key, group_position: 2) }
  let(:valid_physical_object) { FactoryGirl.build(:physical_object, :cdr, unit: physical_object.unit) }
  let(:invalid_physical_object) { FactoryGirl.build(:invalid_physical_object, :cdr, unit: physical_object.unit) }
  let(:group_key) { FactoryGirl.create(:group_key) }

  describe "GET index" do
    before(:each) do
      physical_object
      get :index
    end
    it "populates an array of physical objects" do
      expect(assigns(:physical_objects)).to eq [physical_object]
      expect(assigns(:physical_objects)).to respond_to :total_pages
    end
    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
    include_examples "provides pagination", :physical_objects
  end

  describe "GET show" do
    before(:each) { get :show, id: physical_object.id }

    it "assigns the requested physical object to @physical_object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
      
    it "renders the :show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET new" do
    before(:each) { get :new }
    it "assigns a new PhysicalObject to @physical_object" do
      expect(assigns(:physical_object)).to be_a_new(PhysicalObject)
    end
    it "renders the :new template" do
      expect(response).to render_template(:new)
    end
    context "specifying a group_key" do
      before(:each) { get :new, group_key_id: group_key.id }
      it "assigns @group_key" do
        expect(assigns(:group_key)).to eq group_key
      end
      it "assigns a group_key to @physical_object" do
        expect(assigns(:physical_object).group_key).to eq group_key
      end
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: physical_object.id }
    it "locates the requested object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
    it "renders the :edit template" do
      expect(response).to render_template(:edit) 
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "saves the new physical object in the database" do
        physical_object
        expect{ creation }.to change(PhysicalObject, :count).by(1)
      end
      it "redirects to the objects index" do
        creation
        expect(response).to redirect_to(controller: :physical_objects, action: :index) 
      end
    end

    context "with invalid attributes" do
      #FIXME: test that invalid object is invalid?
      let(:creation) { post :create, physical_object: invalid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "does not save the new physical object in the database" do
        physical_object
        expect{ creation }.not_to change(PhysicalObject, :count)
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
        put :update, id: physical_object.id, physical_object: FactoryGirl.attributes_for(:physical_object, :cdr, title: "Updated title"), tm: FactoryGirl.attributes_for(:cdr_tm) 
      end

      it "locates the requested object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
      it "changes the object's attributes" do
        expect(physical_object.title).not_to eq "Updated title"
        physical_object.reload
        expect(physical_object.title).to eq "Updated title"
      end
      it "redirects to the updated object" do
        expect(response).to redirect_to(controller: :physical_objects, action: :index) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: physical_object.id, physical_object: FactoryGirl.attributes_for(:invalid_physical_object, :cdr), tm: FactoryGirl.attributes_for(:cdr_tm)
      end

      it "locates the requested object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
      it "does not change the object's attributes" do
        expect(physical_object.title).to eq "FactoryGirl object"
        physical_object.reload
        expect(physical_object.title).to eq "FactoryGirl object"
      end
      it "re-renders the :edit template" do
        expect(response).to render_template(:edit)
      end

    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: physical_object.id }
    it "deletes the object" do
      physical_object
      expect{ deletion }.to change(PhysicalObject, :count).by(-1)
    end
    it "redirects to the object index" do
      deletion
      expect(response).to redirect_to physical_objects_path
    end
  end

  describe "GET download_spreadsheet_example" do
    it "downloads example import spreadsheet" do
      expect(controller).to receive(:send_file) { controller.render nothing: true }
      get :download_spreadsheet_example
    end
  end

  describe "GET split_show" do
    let(:split_show) { get :split_show, id: physical_object.id }
    context "on an uncontained object" do
      before(:each) { split_show }
      it "assigns the physical_object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
      it "renders the split_show template" do
        expect(response).to render_template(:split_show)
      end
    end
    shared_examples "rejects action" do
      it "flashes a failure notice" do
        expect(flash[:notice]).to match /must be removed/
      end
      it "redirects to the object" do
        expect(response).to redirect_to(controller: "physical_objects", action: :show, id: physical_object.id)
      end
    end
    context "on a boxed object" do
      before(:each) do
        physical_object.box = FactoryGirl.create(:box)
        physical_object.save
	split_show
      end
      include_examples "rejects action"
    end
    context "on a binned object" do
      before(:each) do
        physical_object.box = FactoryGirl.create(:box)
        physical_object.save
	split_show
      end
      include_examples "rejects action"
    end
  end
  
  describe "PATCH split_update" do
    let(:count) { 3 }
    let(:split_update) { patch :split_update, id: physical_object.id, count: count }
    context "on an unboxed/unbinned item" do
      it "creates additional records" do
        physical_object
        expect{ split_update }.to change(PhysicalObject, :count).by(count - 1)
      end
      it "flashes a success notice" do
        split_update
        expect(flash[:notice]).to eq "<i>#{physical_object.title}</i> was successfully split into #{count} records.".html_safe
  
      end
      it "redirects to the group_key of the split object" do
        split_update
        expect(response).to redirect_to(controller: "group_keys", action: :show, id: physical_object.group_key.id)
      end
    end
    shared_examples "prevents split" do
      it "does not create additional records" do
        physical_object
        expect{ split_update }.not_to change(PhysicalObject, :count)
      end
      it "flashes a failure notice" do
        split_update
        expect(flash[:notice]).to match /must be removed/
      end
      it "redirects to the object" do
        split_update
        expect(response).to redirect_to(controller: "physical_objects", action: "show", id: physical_object.id)
      end
    end
    context "on a boxed item" do
      before(:each) do
        physical_object.box = FactoryGirl.create(:box)
        physical_object.save
      end
      include_examples "prevents split"
    end
    context "on a binned item" do
      before(:each) do
        physical_object.bin = FactoryGirl.create(:bin)
        physical_object.save
      end
      include_examples "prevents split"
    end
  end

  describe "GET upload_show" do
    before(:each) { get :upload_show }
    it "assigns a new physical_object" do
      expect(assigns(:physical_object)).to be_a_new(PhysicalObject)
    end
    it "renders the upload_show template" do
      expect(response).to render_template(:upload_show)
    end
  end

  describe "POST upload_update" do
    context "without specifying a file" do
      before(:each) { post :upload_update }
      it "flashes a notice" do
        expect(flash[:notice]).to eq "Please specify a file to upload"
      end
      it "redirects to upload_show" do
        expect(response).to redirect_to(action: :upload_show)
      end
    end

    describe "with invalid columns headers" do
      context "running header validation" do
        let(:upload_update) { post :upload_update, pl: {name: "", description: ""}, physical_object: { csv_file: fixture_file_upload('files/po_import_invalid_headers.csv', 'text/csv') } }
        it "should NOT create a spreadsheet object" do
          expect{ upload_update}.not_to change(Spreadsheet, :count)
        end
      end
      context "skipping header validation" do
        let(:upload_update) { post :upload_update, pl: {name: "", description: ""}, physical_object: { csv_file: fixture_file_upload('files/po_import_invalid_headers.csv', 'text/csv') }, header_validation: "false" }
        it "should create a spreadsheet object" do
          expect{ upload_update}.to change(Spreadsheet, :count).by(1)
        end
      end
    end

    ["po_import_cdr.csv", "po_import_DAT.csv", "po_import_orat.csv", "po_import_lp.csv"].each do |filename|
      context "specifying a file (#{filename}) and picklist" do
        let(:upload_update) { post :upload_update, pl: { name: "Test picklist", description: "Test description"}, physical_object: { csv_file: fixture_file_upload('files/' + filename, 'text/csv') } }
        it "should create a spreadsheet object" do
          expect{ upload_update }.to change(Spreadsheet, :count).by(1)
          expect(Spreadsheet.last.filename).to eq filename
        end
        it "should create a picklist" do
          expect{ upload_update }.to change(Picklist, :count).by(1)
        end
        it "flashes a success notice" do
          upload_update
          expect(flash[:notice]).to eq "Spreadsheet uploaded.<br/>2 records were successfully imported.".html_safe
        end
        it "creates records" do
          expect{ upload_update }.to change(PhysicalObject, :count).by(2)
        end
        it "creates records no older than spreadsheet" do
          upload_update
          spreadsheet = Spreadsheet.last
          objects = PhysicalObject.where(spreadsheet_id: spreadsheet.id)
          objects.each do |object|
            expect(object.updated_at).to be <= spreadsheet.created_at
          end
        end
        it "fails if repeated, due to duplicate filename" do
          upload_update
          expect{ upload_update }.not_to change(Spreadsheet, :count)
        end
      end
    end
  end

  describe "POST unbin" do
    let(:post_unbin) { post :unbin, id: physical_object.id }
    context "when in a box" do
      let(:box) { FactoryGirl.create(:box) }
      before(:each) do
        physical_object.box = box
        physical_object.save
      end
      it "raises an error" do
        expect{ post_unbin }.to raise_error RuntimeError
      end
    end
    context "when not in a bin" do
      before(:each) do
        physical_object.box = nil
        physical_object.bin = nil
        physical_object.save
        post_unbin
      end
      it "displays an error message" do
        expect(flash[:notice]).to eq "<strong>Physical Object was not associated to a Bin.</strong>".html_safe
      end
      it "redirects to the object" do
        expect(response).to redirect_to physical_object
      end
    end
    context "when in a bin" do
      let(:bin) { FactoryGirl.create(:bin) }
      before(:each) do
        physical_object.box = nil
        physical_object.bin = bin
        physical_object.save
        post_unbin
      end
      it "displays a success message" do
        expect(flash[:notice]).to eq "<em>Physical Object was successfully removed from bin.</em>".html_safe
      end
      it "unbins the object" do
        expect(physical_object.bin).not_to be_nil
        physical_object.reload
        expect(physical_object.bin).to be_nil
      end
      it "redirects to the bin" do
        expect(response).to redirect_to bin
      end
    end
  end

  describe "POST unbox" do
    let(:post_unbox) { post :unbox, id: physical_object.id }
    context "when not in a box" do
      before(:each) do
        physical_object.box = nil
        physical_object.save
        post_unbox
      end
      it "displays an error message" do
        expect(flash[:notice]).to eq "<strong>Physical Object was not associated to a Box.</strong>".html_safe
      end
      it "redirects to the object" do
        expect(response).to redirect_to physical_object
      end
    end
    context "when in a box" do
      let(:box) { FactoryGirl.create(:box) }
      before(:each) do
        physical_object.box = box
        physical_object.save
        post_unbox
      end
      it "displays a success message" do
        expect(flash[:notice]).to eq "<em>Physical Object was successfully removed from box.</em>".html_safe
      end
      it "unboxes the object" do
        expect(physical_object.box).not_to be_nil
        physical_object.reload
        expect(physical_object.box).to be_nil
      end
      it "redirects to the box" do
        expect(response).to redirect_to box
      end
    end
  end

  describe "POST unpick" do
    let(:post_unpick_missing_barcode) { post :unpick, id: physical_object.id }
    let(:post_unpick_with_same_barcode) { post :unpick, id: physical_object.id, mdpi_barcode: physical_object.mdpi_barcode }
    let(:post_unpick_with_valid_barcode) { post :unpick, id: physical_object.id, mdpi_barcode: valid_mdpi_barcode }
    let(:post_unpick_with_invalid_barcode) { post :unpick, id: physical_object.id, mdpi_barcode: invalid_mdpi_barcode }
    let(:removed_message) { "The Physical Object was removed from the Pick List."}
    let(:updated_message) { "The Physical Object was removed from the Pick List and its barcode updated." }

    shared_examples "flashes successful removal message" do
      it "displays a success message" do
        expect(flash[:notice]).to eq removed_message
      end
    end
    shared_examples "flashes successful update message" do
      it "displays a success message" do
        expect(flash[:notice]).to eq updated_message
      end
    end
    shared_examples "unpicks the object" do
      it "disassociates the object from the picklist" do
        physical_object.reload
        expect(physical_object.picklist).to be_nil
      end
      it "disassociates other objects in the same group from the picklist" do
        physical_object.reload
        physical_object.group_key.physical_objects.each do |object|
          expect(object.picklist).to be_nil if object.id != physical_object.id
        end
      end
    end

    context "when not in a picklist" do
      before(:each) do 
        physical_object.picklist = nil
        physical_object.save
        post_unpick_with_same_barcode
      end
      include_examples "flashes successful removal message"
      include_examples "unpicks the object"
    end
    context "when in a picklist" do
      let(:picklist) { FactoryGirl.create(:picklist) }
      before(:each) do
        physical_object.picklist = picklist
        physical_object.save
        second_object.picklist = picklist
        second_object.save
      end
      context "setting the same barcode" do
        before(:each) { post_unpick_with_same_barcode }
        include_examples "flashes successful removal message"
        include_examples "unpicks the object"
      end
      context "not sending a barcode parameter" do
        before(:each) { post_unpick_missing_barcode }
        include_examples "flashes successful removal message"
        include_examples "unpicks the object"
      end
      context "sending an updated valid barcode" do
        before(:each) { post_unpick_with_valid_barcode }
        include_examples "flashes successful update message"
        include_examples "unpicks the object"
      end
      context "sending an invalid barcode" do
        before(:each) { post_unpick_with_invalid_barcode }
        include_examples "flashes successful removal message"
        include_examples "unpicks the object"
      end
    end
  end

  describe "POST ungroup" do
    let(:ungroup) {
      request.env["HTTP_REFERER"] = "source_page"
      post :ungroup, id: physical_object.id
    }
    it "removes the existing group key association" do
      original_group = physical_object.group_key
      ungroup
      physical_object.reload
      expect(physical_object.group_key).not_to eq original_group
    end
    it "indirectly adds a new group key association" do
      ungroup
      expect(physical_object.group_key).not_to be_nil
    end
    it "resets the group_position to 1" do
      physical_object.group_position = 2
      physical_object.save
      ungroup
      physical_object.reload
      expect(physical_object.group_position).to eq 1
    end
    it "redirects to :back" do
      ungroup
      expect(response).to redirect_to "source_page"
    end
  end

  describe "POST has_ephemera" do
    let(:post_has_ephemera) { post :has_ephemera, mdpi_barcode: physical_object.mdpi_barcode }
    it "returns 'true' when ephemera present" do
      physical_object.has_ephemera = true
      physical_object.save
      post_has_ephemera
      expect(response.body).to eq "true"
    end
    it "returns 'false' when ephemera not present" do
      physical_object.has_ephemera = false
      physical_object.save
      post_has_ephemera
      expect(response.body).to eq "false"
    end
    it "returns 'unknown physical Object' when physical object not found" do
      post :has_ephemera
      expect(response.body).to eq "unknown physical Object"
    end
  end

end
