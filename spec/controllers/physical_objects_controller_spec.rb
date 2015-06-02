require 'rails_helper'
require 'debugger'

describe PhysicalObjectsController do
  render_views
  before(:each) { sign_in }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr) }
  let(:barcoded_object) { FactoryGirl.create(:physical_object, :cdr, :barcoded) }
  let(:second_object) { FactoryGirl.create(:physical_object, :cdr, unit: physical_object.unit, group_key: physical_object.group_key, group_position: 2) }
  let(:valid_physical_object) { FactoryGirl.build(:physical_object, :cdr, unit: physical_object.unit) }
  let(:invalid_physical_object) { FactoryGirl.build(:invalid_physical_object, :cdr, unit: physical_object.unit) }
  let(:group_key) { FactoryGirl.create(:group_key) }
  let(:picklist) { FactoryGirl.create(:picklist) }

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

  describe "GET edit_ephemera" do
    before(:each) { get :edit_ephemera, id: physical_object.id }
    it "locates the requested object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
    it "renders the :edit_ephemera template" do
      expect(response).to render_template(:edit_ephemera) 
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), dp: valid_physical_object.digital_provenance.attributes.symbolize_keys}
      it "saves the new physical object in the database" do
        physical_object
        expect{ creation }.to change(PhysicalObject, :count).by(1)
      end
      it "redirects to the objects index" do
        creation
        expect(response).to redirect_to(controller: :physical_objects, action: :index) 
      end
      it "saved digiprov" do
        physical_object.reload
        expect(physical_object.digital_provenance).not_to be nil
      end
    end

    context "with invalid attributes" do
      #FIXME: test that invalid object is invalid?
      let(:creation) { post :create, physical_object: invalid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), dp: invalid_physical_object.digital_provenance.attributes.symbolize_keys }
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

  describe "PATCH update_ephemera" do
    before(:each) { put :update_ephemera, id: physical_object.id, physical_object: ephemera_values }
    context "with the same attributes" do
      let(:ephemera_values) { { has_ephemera: physical_object.has_ephemera, ephemera_returned: physical_object.ephemera_returned } }
      it "locates the requested object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
      it "flashes inaction warning" do
        expect(flash[:warning]).to match /no.*change/i
      end
    end
    context "with modified attributes" do
      let(:ephemera_values) { { has_ephemera: !physical_object.has_ephemera?, ephemera_returned: !physical_object.ephemera_returned? } }
      it "locates the requested object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
      it "changes the ephemera attributes" do
        expect(physical_object.has_ephemera).not_to eq ephemera_values[:has_ephemera]
        expect(physical_object.ephemera_returned).not_to eq ephemera_values[:ephemera_returned]
        physical_object.reload
        expect(physical_object.has_ephemera).to eq ephemera_values[:has_ephemera]
        expect(physical_object.ephemera_returned).to eq ephemera_values[:ephemera_returned]
      end
      it "records a new workflow status history entry" do
        original_status, updated_status = physical_object.workflow_statuses[-2..-1]
        expect(original_status.workflow_status_template_id).to eq updated_status.workflow_status_template_id
        expect(original_status.has_ephemera).not_to eq updated_status.has_ephemera
        expect(original_status.ephemera_returned).not_to eq updated_status.ephemera_returned
      end
      it "flashes success notice" do
        expect(flash[:notice]).to match /success/i
      end
    end
  end

  describe "PUT update" do
    context "with valid attributes" do
      before(:each) do
        put :update, id: physical_object.id, physical_object: FactoryGirl.attributes_for(:physical_object, :cdr, title: "Updated title"), tm: FactoryGirl.attributes_for(:cdr_tm), dp: physical_object.digital_provenance.attributes.symbolize_keys
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
      it "saved digiprov" do
        physical_object.reload
        expect(physical_object.digital_provenance).not_to be nil
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
    describe "sets correct automatic status values:" do
      let(:unassigned_params) { { picklist_id: nil, mdpi_barcode: 0 } }
      let(:on_pick_list_params) { { picklist_id: picklist.id, mdpi_barcode: 0} }
      let(:barcoded_params) { { picklist_id: picklist.id, mdpi_barcode: valid_mdpi_barcode } }

      specify "Unassigned for empty params" do
        put :update, id: physical_object.id, physical_object: unassigned_params, tm: FactoryGirl.attributes_for(:cdr_tm), dp: physical_object.digital_provenance.attributes.symbolize_keys
        physical_object.reload
        expect(physical_object.current_workflow_status).to eq "Unassigned"
      end
      specify "On Pick List for picklist assignment" do
        put :update, id: physical_object.id, physical_object: on_pick_list_params, tm: FactoryGirl.attributes_for(:cdr_tm), dp: physical_object.digital_provenance.attributes.symbolize_keys
        physical_object.reload
        expect(physical_object.current_workflow_status).to eq "On Pick List"
      end
      specify "On Pick List for picklist + barcode" do
        put :update, id: physical_object.id, physical_object: barcoded_params, tm: FactoryGirl.attributes_for(:cdr_tm), dp: physical_object.digital_provenance.attributes.symbolize_keys
        physical_object.reload
        expect(physical_object.current_workflow_status).to eq "On Pick List"
      end
      specify "Reverts to Unassigned after On Pick List" do
        put :update, id: physical_object.id, physical_object: barcoded_params, tm: FactoryGirl.attributes_for(:cdr_tm), dp: physical_object.digital_provenance.attributes.symbolize_keys
        put :update, id: physical_object.id, physical_object: unassigned_params, tm: FactoryGirl.attributes_for(:cdr_tm), dp: physical_object.digital_provenance.attributes.symbolize_keys
        physical_object.reload
        expect(physical_object.current_workflow_status).to eq "Unassigned"
        expect(physical_object.workflow_statuses.size).to be >= 3 # Unassigned, On Pick List, Unassigned
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

  describe "GET workflow_history" do
    before(:each) { get :workflow_history, id: physical_object.id }

    it "assigns the requested physical object to @physical_object" do
      expect(assigns(:physical_object)).to eq physical_object
    end

    it "assigns the worfklow history to @workflow_statuses" do
      expect(assigns(:workflow_statuses)).to eq physical_object.workflow_statuses
    end

    it "renders the :workflow_history template" do
      expect(response).to render_template(:workflow_history)
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
        physical_object.save!
        split_show
      end
      include_examples "rejects action"
    end
    context "on a binned object" do
      before(:each) do
        physical_object.format = "Open Reel Audio Tape"
        physical_object.bin = FactoryGirl.create(:bin)
        physical_object.save!
        split_show
      end
      include_examples "rejects action"
    end
  end
  
  describe "PATCH split_update" do
    let(:count) { 3 }
    # params[:grouped] = "on" keeps objects in same group
    let(:split_args) { { id: physical_object.id, count: count } }
    let(:split_update) do 
      request.env["HTTP_REFERER"] = source_page
      patch :split_update, split_args
    end
    shared_examples "split behavior" do
      shared_examples "prevents split" do
        it "does not create additional records" do
          physical_object
          expect{ split_update }.not_to change(PhysicalObject, :count)
        end
        it "flashes a failure notice" do
          split_update
          expect(flash[:notice]).to match /must be removed/
        end
        it "redirects to :back/pack_list" do
          split_update
          expect(response).to redirect_to destinations[:ungrouped]
        end
      end
      shared_examples "does not split" do
        it "does not create additional records" do
          physical_object
          expect{ split_update }.not_to change(PhysicalObject, :count)
        end
        it "flashes an inaction notice" do
          split_update
          expect(flash[:notice]).to match /NOT split/i
        end
        it "redirects to :back/pack_list" do
          split_update
          expect(response).to redirect_to destinations[:ungrouped]
        end
      end
      context "on a boxed item" do
        before(:each) do
          physical_object.box = FactoryGirl.create(:box)
          physical_object.save!
        end
        include_examples "prevents split"
      end
      context "on a binned item" do
        before(:each) do
          physical_object.format = "Open Reel Audio Tape"
          physical_object.bin = FactoryGirl.create(:bin)
          physical_object.save!
        end
        include_examples "prevents split"
      end
      context "on an unboxed/unbinned item" do
        context "with count less than or equal to 1" do
          let(:count) { 0 }
          include_examples "does not split"
        end
        context "with count greater than 1" do
          context "keeping the same group key" do
            before(:each) { split_args[:grouped] = "on" }
            it "creates additional objects" do
              physical_object
              expect{ split_update }.to change(PhysicalObject, :count).by(count - 1)
            end
            it "does not create additional group keys" do
              physical_object
              expect{ split_update }.not_to change(GroupKey, :count)
            end
            it "updates group position on objects" do
              physical_object
              split_update
              expect(PhysicalObject.last.group_position).to eq count
            end
            it "flashes a success notice" do
              split_update
              expect(flash[:notice]).to eq "<i>#{physical_object.title}</i> was successfully split into #{count} records.".html_safe

            end
            it "redirects to :back/group_key/pack_list" do
              split_update
              expect(response).to redirect_to destinations[:grouped]
            end
          end
          context "changing the group key" do
            it "creates additional objects" do
              physical_object
              expect{ split_update }.to change(PhysicalObject, :count).by(count - 1)
            end
            it "creates additional group keys" do
              physical_object
              expect{ split_update }.to change(GroupKey, :count).by(count - 1)
            end
            it "does not update group position on objects" do
              physical_object
              split_update
              expect(PhysicalObject.last.group_position).to eq 1
            end
            it "flashes a success notice" do
              split_update
              expect(flash[:notice]).to eq "<i>#{physical_object.title}</i> was successfully split into #{count} records.".html_safe

            end
            it "redirects to :back/physical_object/pack_list" do
              split_update
              expect(response).to redirect_to destinations[:ungrouped]
            end
          end
        end
      end
    end
    context "from split_show" do
      let(:source_page) { split_show_physical_object_path(physical_object) }
      let(:destinations) { { grouped: group_key_path(physical_object.group_key), ungrouped: physical_object_path(physical_object) } }
      include_examples "split behavior"
    end
    context "from pack_list, generally" do
      let(:source_page) { pack_list_picklist_path(picklist.id) }
      let(:dest_page) { pack_list_picklist_path(picklist.id, physical_object: { id: physical_object.id }) }
      let(:destinations) { { grouped: dest_page, ungrouped: dest_page } }
      include_examples "split behavior"
    end
    context "from pack_list, specific item" do
      let(:source_page) { pack_list_picklist_path(picklist.id, physical_object: { id: physical_object.id }) }
      let(:dest_page) { pack_list_picklist_path(picklist.id, physical_object: { id: physical_object.id }) }
      let(:destinations) { { grouped: dest_page, ungrouped: dest_page } }
      include_examples "split behavior"
    end
    context "from other sources (not split_show, not pack_list)" do
      let(:source_page) { "source_page" }
      let(:destinations) { { grouped: source_page, ungrouped: source_page } }
      include_examples "split behavior"
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
      it "redirects to :back" do
        split_update
        expect(response).to redirect_to "source_page"
      end
    end
    context "on a boxed item" do
      let(:source_page) { "source_page" }
      before(:each) do
        physical_object.box = FactoryGirl.create(:box)
        physical_object.save!
      end
      include_examples "prevents split"
    end
    context "on a binned item" do
      let(:source_page) { "source_page" }
      before(:each) do
        physical_object.format = "Open Reel Audio Tape"
        physical_object.bin = FactoryGirl.create(:bin)
        physical_object.save!
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
    describe "without choosing a picklist association option" do
      before(:each) { post :upload_update }
      it "flashes a notice" do
        expect(flash[:notice]).to match /choose.*picklist association/
      end
      it "redirects to upload_show" do
        expect(response).to redirect_to(action: :upload_show)
      end
    end
    describe "associating to a new picklist" do
      context "not providing a name" do
        before(:each) { post :upload_update, type: "new", picklist: {} }
        it "flashes a notice" do
          expect(flash[:notice]).to match /picklist.*name/
        end
        it "redirects to upload_show" do
          expect(response).to redirect_to(action: :upload_show)
        end
      end
    end
    describe "without specifying a file" do
      before(:each) { post :upload_update, type: "none" }
      it "flashes a notice" do
        expect(flash[:notice]).to match /please.*specify.*file/i
      end
      it "redirects to upload_show" do
        expect(response).to redirect_to(action: :upload_show)
      end
    end
    describe "with invalid columns headers" do
      context "running header validation" do
        let(:upload_update) { post :upload_update, type: "none", physical_object: { csv_file: fixture_file_upload('files/po_import_invalid_headers.csv', 'text/csv') } }
        it "should NOT create a spreadsheet object" do
          expect{ upload_update}.not_to change(Spreadsheet, :count)
        end
      end
      context "skipping header validation" do
        let(:upload_update) { post :upload_update, type: "none", physical_object: { csv_file: fixture_file_upload('files/po_import_invalid_headers.csv', 'text/csv') }, header_validation: "false" }
        it "should create a spreadsheet object" do
          expect{ upload_update}.to change(Spreadsheet, :count).by(1)
        end
      end
    end

    shared_examples "upload results" do |filename|
      it "should create a spreadsheet object" do
        expect{ upload_update }.to change(Spreadsheet, :count).by(1)
        expect(Spreadsheet.last.filename).to eq filename
      end
      it "flashes a success notice" do
        upload_update
        expect(flash[:notice]).to match /Spreadsheet uploaded.<br\/>2 records were successfully imported./
      end
      it "creates physical object records" do
        expect{ upload_update }.to change(PhysicalObject, :count).by(2)
      end
      it "creates technical metadatum records" do
        expect{ upload_update }.to change(TechnicalMetadatum, :count).by(2)
      end
      it "creates records no older than spreadsheet" do
        upload_update
        spreadsheet = Spreadsheet.last
        objects = PhysicalObject.where(spreadsheet_id: spreadsheet.id)
        objects.each do |object|
          expect(object.updated_at).to be <= spreadsheet.created_at
        end
      end
      it "creates a Bin record" do
        expect{ upload_update }.to change(Bin, :count).by(1)
      end
      it "creates Condition Status records" do
        expect{ upload_update }.to change(ConditionStatus, :count).by(2) 
      end
      it "creates Note records" do
        expect{ upload_update }.to change(Note, :count).by(2) 
      end
      it "fails if repeated, due to duplicate filename" do
        upload_update
        expect{ upload_update }.not_to change(Spreadsheet, :count)
      end
    end

    ["po_import_cdr.csv", "po_import_cdr_iso-8559-1.csv", "po_import_cdr.xlsx", "po_import_DAT.csv", "po_import_orat.csv", "po_import_lp.csv"].each do |filename|
      context "specifying a file: #{filename}" do
        let(:post_args) { { physical_object: { csv_file: fixture_file_upload('files/' + filename, 'text/csv') } } }
        let(:upload_update) { post :upload_update, **post_args }
        describe "and no picklist" do
          before(:each) do
            post_args[:type] = "none"
          end
          include_examples "upload results", filename
          it "does not create a picklist" do
            expect{ upload_update }.not_to change(Picklist, :count)
          end
        end
        context "and an existing picklist" do
          before(:each) { post_args[:type] = "existing" }
          describe "selected" do
            before(:each) do
              picklist
              post_args[:picklist] = { id: picklist.id }
            end
            include_examples "upload results", filename
            it "uses the selected picklist" do
              upload_update
              expect(assigns[:picklist]).to eq picklist
            end
          end
          describe "not selected" do
            before(:each) do
              post_args[:picklist] = {}
              upload_update
            end
            it "flashes inaction" do
              expect(flash[:notice]).to match /select.*picklist/i
            end
            it "redirects to upload_show" do
              expect(response).to redirect_to(action: :upload_show)
            end
          end
        end
        context "and a new picklist" do
          before(:each) { post_args[:type] = "new" }
          describe "with a new name" do
            before(:each) do
              post_args[:picklist] = { name: "Test picklist", description: "Test description" }
            end
            include_examples "upload results", filename
            it "creates a picklist" do
              expect{ upload_update }.to change(Picklist, :count).by(1)
            end
            it "flashes a picklist creation message" do
              upload_update
              expect(flash[:notice]).to match /Created picklist/
            end
          end 
          describe "with a name collision" do
            before(:each) do
              picklist
              post_args[:picklist] = { name: picklist.name }
              upload_update
            end
            it "flashes error warning" do
              expect(flash[:warning]).to match /error/i
            end
            it "redirects to upload_show" do
              expect(response).to redirect_to(action: :upload_show)
            end
          end
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
        physical_object.save!
      end
      it "raises an error" do
        expect{ post_unbin }.to raise_error RuntimeError
      end
    end
    context "when not in a bin" do
      before(:each) do
        physical_object.box = nil
        physical_object.bin = nil
        physical_object.save!
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
        physical_object.format = "Open Reel Audio Tape"
        physical_object.box = nil
        physical_object.bin = bin
        physical_object.save!
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
      it "removes the Binned status" do
        expect(physical_object.current_workflow_status).to eq "Binned"
        physical_object.reload
        expect(physical_object.current_workflow_status).not_to eq "Binned"
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
        physical_object.save!
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
        physical_object.save!
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
      it "removes the Boxed status" do
        expect(physical_object.current_workflow_status).to eq "Boxed"
        physical_object.reload
        expect(physical_object.current_workflow_status).not_to eq "Boxed"
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
        # not necessarily associated to a pick list to start with, under these tests
        physical_object.reload
        expect(physical_object.picklist).to be_nil
      end
      it "removes the On Pick List status" do
        # not necessarily "On Pick List" to start with, under these tests
        physical_object.reload
        expect(physical_object.current_workflow_status).not_to eq "On Pick List"
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
        physical_object.save!
        post_unpick_with_same_barcode
      end
      include_examples "flashes successful removal message"
      include_examples "unpicks the object"
    end
    context "when in a picklist" do
      let(:picklist) { FactoryGirl.create(:picklist) }
      before(:each) do
        physical_object.picklist = picklist
        physical_object.save!
        second_object.picklist = picklist
        second_object.save!
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
      physical_object.save!
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
    let(:post_has_ephemera) { post :has_ephemera, mdpi_barcode: barcoded_object.mdpi_barcode }
    it "returns 'true' when ephemera present" do
      barcoded_object.has_ephemera = true
      barcoded_object.save!
      post_has_ephemera
      expect(response.body).to eq "true"
    end
    it "returns 'false' when ephemera not present" do
      barcoded_object.has_ephemera = false
      barcoded_object.save!
      post_has_ephemera
      expect(response.body).to eq "false"
    end
    it "returns 'unknown physical Object' when physical object not found" do
      post :has_ephemera, mdpi_barcode: 1234
      expect(response.body).to eq "unknown physical Object"
    end
    it "returns 'unknown physical Object' when given a 0 barcode" do
      physical_object
      post :has_ephemera, mdpi_barcode: 0
      expect(response.body).to eq "unknown physical Object"
    end
    it "returns 'returned' when item has already been marked returned" do
      barcoded_object.current_workflow_status = "Unpacked"
      barcoded_object.save!
      post_has_ephemera
      expect(response.body).to eq 'returned'
    end
  end

  describe "GET edit_ephemera" do
    pending "FIXME: needs tests"
  end

  describe "PATCH update_ephemera" do
    pending "FIXME: needs tests"
  end

end
