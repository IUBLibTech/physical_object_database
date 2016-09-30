describe PhysicalObjectsController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr) }
  let(:picklist_specification) { FactoryGirl.create(:picklist_specification, :cdr) }
  let(:barcoded_object) { FactoryGirl.create(:physical_object, :cdr, :barcoded) }
  let(:second_object) { FactoryGirl.create(:physical_object, :cdr, unit: physical_object.unit, group_key: physical_object.group_key, group_position: 2) }
  let(:valid_physical_object) { FactoryGirl.build(:physical_object, :cdr, unit: physical_object.unit) }
  let(:invalid_physical_object) { FactoryGirl.build(:invalid_physical_object, :cdr, unit: physical_object.unit) }
  let(:boxed_physical_object) { FactoryGirl.build(:physical_object, :cdr, :barcoded, unit: physical_object.unit, box: box, picklist: picklist) }
  let(:binned_physical_object) { FactoryGirl.build(:physical_object, :betacam, :barcoded, unit: physical_object.unit, bin: bin, picklist: picklist) }
  let(:group_key) { FactoryGirl.create(:group_key) }
  let(:picklist) { FactoryGirl.create(:picklist) }
  let(:shipment) { FactoryGirl.create(:shipment) }
  let(:full_box) { FactoryGirl.create(:box, full: true) }
  let(:box) { FactoryGirl.create(:box) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:sealed_bin) { bin.current_workflow_status = "Sealed"; bin.save!; bin }
  CARRYOVER_ATTRIBUTES = [:format, :unit_id, :picklist_id, :box_id, :bin_id, :collection_identifier, :collection_name, :shipment_id]

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
    shared_examples "common GET show behaviors" do
      [action: "show", edit_mode: false, display_assigned: true].each do |var, value|
        it "assigns @#{var} to '#{value}'" do
          expect(assigns(var)).to eq value
        end
      end
      it "assigns the requested physical object to @physical_object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
    end
    context "from quality_control" do
      before(:each) do
        request.env['HTTP_REFERER'] = 'quality_control'
        get :show, id: physical_object.id
      end
      it "redirects to digital_provenance_path" do
        expect(response).to redirect_to digital_provenance_path(physical_object.id)
      end
    end
    context "from anywhere else" do
      before(:each) { get :show, id: physical_object.id }
      include_examples "common GET show behaviors"
      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
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
    shared_examples "common failed POST create behaviors" do
      it "does not save the new physical object in the database" do
        physical_object
        expect{ creation }.not_to change(PhysicalObject, :count)
      end
      it "re-renders the :new template" do
        creation
        expect(response).to render_template(:new)
      end
    end
    context "with valid attributes" do
      shared_examples "common successful POST create behaviors" do
        it "saves the new physical object in the database" do
          physical_object
          expect{ creation }.to change(PhysicalObject, :count).by(1)
        end
        it "saved digiprov" do
          physical_object
          expect(PhysicalObject.last.digital_provenance).not_to be nil
        end
      end
      context "without repeat" do
        let(:creation) { post :create, physical_object: boxed_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm)}
        include_examples "common successful POST create behaviors"
        it "redirects to the objects index" do
          creation
          expect(response).to redirect_to(controller: :physical_objects, action: :index) 
        end
      end
      context "with repeat: true" do
        let(:title) { "repeated title" }
        let(:creation) { post :create, repeat: 'true', grouped: grouped, physical_object: chosen_po.attributes.symbolize_keys.merge(title: title), tm: FactoryGirl.attributes_for(chosen_factory)}
        shared_examples "common successful repeat creation behaviors" do
          include_examples "common successful POST create behaviors"
          it "assigns a new @physical_object" do
            creation
            expect(assigns(:physical_object)).to be_a_new PhysicalObject
          end
          specify "assigns carry-over attributes to new physical object" do
            creation
            CARRYOVER_ATTRIBUTES.each do |att|
              expect(assigns(:physical_object).send(att)).to eq chosen_po.send(att)
            end
          end
          it "loses non-carryover attributes (with grouping contingent on parameter)" do
            creation
            expect(assigns(:physical_object).title).to be_blank
            assigns(:physical_object).attributes.keys.each do |att|
              unless att.to_sym.in?(CARRYOVER_ATTRIBUTES + [:group_key_id, :group_position])
                expect(assigns(:physical_object).send(att)).to be_blank
              end
            end
          end
          it "renders the :new template" do
            creation
            expect(response).to render_template :new
          end
        end
        context "with grouped: false" do
          let(:grouped) { 'false' }
          context "on a boxed object" do
            let(:chosen_po) {  boxed_physical_object }
            let(:chosen_factory) { :cdr_tm }
            include_examples "common successful repeat creation behaviors"
            it "does not assign a group key" do
              creation
              expect(assigns(:physical_object).group_key).to be_nil
            end
          end
          context "on a binned object" do
            let(:chosen_po) {  binned_physical_object }
            let(:chosen_factory) { :betacam_tm }
            include_examples "common successful repeat creation behaviors"
            it "does not assign a group key" do
              creation
              expect(assigns(:physical_object).group_key).to be_nil
            end
          end
        end
        context "with grouped: true" do
          let(:grouped) { 'true' }
          context "on a boxed object" do
            let(:chosen_po) {  boxed_physical_object }
            let(:chosen_factory) { :cdr_tm }
            include_examples "common successful repeat creation behaviors"
            it "assigns a group key" do
              creation
              expect(assigns(:physical_object).group_key).not_to be_nil
              expect(assigns(:group_key)).not_to be_nil
            end
            it "increments the group_position" do
              creation
              expect(assigns(:physical_object).group_position).to be > 1
            end
          end
          context "on a binned object" do
            let(:chosen_po) {  binned_physical_object }
            let(:chosen_factory) { :betacam_tm }
            include_examples "common successful repeat creation behaviors"
            it "assigns a group key" do
              creation
              expect(assigns(:physical_object).group_key).not_to be_nil
              expect(assigns(:group_key)).not_to be_nil
            end
            it "increments the group_position" do
              creation
              expect(assigns(:physical_object).group_position).to be > 1
            end
          end

        end
      end
    end
    context "with invalid attributes" do
      let(:creation) { post :create, physical_object: invalid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      include_examples "common failed POST create behaviors"
    end
    context "assigning to a non-existant box" do
      let(:creation) { post :create, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), box_mdpi_barcode: 42 }
      include_examples "common failed POST create behaviors"
      it "assigns errors[:box]" do
        creation
        expect(assigns(:physical_object).errors[:box]).not_to be_empty
        expect(assigns(:physical_object).errors[:box].first).to match /No Box found/
      end
    end
    context "assigning to a full box" do
      let(:creation) { post :create, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), box_mdpi_barcode: full_box.mdpi_barcode }
      include_examples "common failed POST create behaviors"
      it "assigns errors[:box]" do
        creation
        expect(assigns(:physical_object).errors[:box]).not_to be_empty
        expect(assigns(:physical_object).errors[:box].first).to match /is full/
      end
    end
    context "assigning to a non-existent bin" do
      let(:creation) { post :create, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), bin_mdpi_barcode: 42 }
      include_examples "common failed POST create behaviors"
      it "assigns errors[:bin]" do
        creation
        expect(assigns(:physical_object).errors[:bin]).not_to be_empty
        expect(assigns(:physical_object).errors[:bin].first).to match /No Bin found/i
      end
    end
    context "assigning to a sealed bin" do
      let(:creation) { post :create, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), bin_mdpi_barcode: sealed_bin.mdpi_barcode }
      include_examples "common failed POST create behaviors"
      it "assigns errors[:bin]" do
        creation
        expect(assigns(:physical_object).errors[:bin]).not_to be_empty
        expect(assigns(:physical_object).errors[:bin].first).to match /is sealed/
      end
    end
  end

  describe "GET create_multiple" do
    before(:each) { get :create_multiple }
    it "assigns @repeat=true" do
      expect(assigns(:repeat)).to eq true
    end
    it "renders :create_multiple template" do
      expect(response).to render_template :create_multiple
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

  describe "Directions recorded" do
    let!(:dr_po) { FactoryGirl.create(:physical_object, :open_reel, title: "Some title") }
    context "creation" do
      it "intializes calculated_directions_recorded and copies value to directions_recorded" do
        expect(dr_po).to be_valid
        expect(dr_po.technical_metadatum).not_to be_nil
        expect(dr_po.technical_metadatum.specific.calculated_directions_recorded).to eq 2
        expect(dr_po.technical_metadatum.specific.directions_recorded).to eq 2
      end
    end

    context "POST #update" do
      before(:each) do
        put :update, id: dr_po.id, physical_object: FactoryGirl.attributes_for(:physical_object, :open_reel, title: "Updated title"), tm: FactoryGirl.attributes_for(:open_reel_tm, directions_recorded: 5)
      end
      it "updates directions_recorded" do
        dr_po.reload
        expect(dr_po.technical_metadatum).not_to be_nil
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
    context "assigning to a non-existent box" do
      before(:each) do
        put :update, id: physical_object.id, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), box_mdpi_barcode: 42
      end
      it "assigns errors[:box]" do
        expect(assigns(:physical_object).errors[:box]).not_to be_empty
        expect(assigns(:physical_object).errors[:box].first).to match /No Box found/i
      end
    end
    context "assigning to a full box" do
      before(:each) do
        put :update, id: physical_object.id, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), box_mdpi_barcode: full_box.mdpi_barcode
      end
      it "assigns errors[:box]" do
        expect(assigns(:physical_object).errors[:box]).not_to be_empty
        expect(assigns(:physical_object).errors[:box].first).to match /is full/
      end
    end
    context "assigning to a non-existent bin" do
      before(:each) do
        put :update, id: physical_object.id, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), bin_mdpi_barcode: 42
      end
      it "assigns errors[:bin]" do
        expect(assigns(:physical_object).errors[:bin]).not_to be_empty
        expect(assigns(:physical_object).errors[:bin].first).to match /No Bin found/i
      end
    end
    context "assigning to a sealed bin" do
      before(:each) do
        put :update, id: physical_object.id, physical_object: valid_physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm), bin_mdpi_barcode: sealed_bin.mdpi_barcode 
      end
      it "assigns errors[:bin]" do
        expect(assigns(:physical_object).errors[:bin]).not_to be_empty
        expect(assigns(:physical_object).errors[:bin].first).to match /is sealed/
      end
    end
    describe "sets correct automatic status values:" do
      let(:unassigned_params) { { picklist_id: nil, mdpi_barcode: 0 } }
      let(:on_pick_list_params) { { picklist_id: picklist.id, mdpi_barcode: 0} }
      let(:barcoded_params) { { picklist_id: picklist.id, mdpi_barcode: valid_mdpi_barcode } }

      specify "Unassigned for empty params" do
        put :update, id: physical_object.id, physical_object: unassigned_params, tm: FactoryGirl.attributes_for(:cdr_tm)
        physical_object.reload
        expect(physical_object.current_workflow_status).to eq "Unassigned"
      end
      specify "On Pick List for picklist assignment" do
        put :update, id: physical_object.id, physical_object: on_pick_list_params, tm: FactoryGirl.attributes_for(:cdr_tm)
        physical_object.reload
        expect(physical_object.current_workflow_status).to eq "On Pick List"
      end
      specify "On Pick List for picklist + barcode" do
        put :update, id: physical_object.id, physical_object: barcoded_params, tm: FactoryGirl.attributes_for(:cdr_tm)
        physical_object.reload
        expect(physical_object.current_workflow_status).to eq "On Pick List"
      end
      specify "Reverts to Unassigned after On Pick List" do
        put :update, id: physical_object.id, physical_object: barcoded_params, tm: FactoryGirl.attributes_for(:cdr_tm)
        put :update, id: physical_object.id, physical_object: unassigned_params, tm: FactoryGirl.attributes_for(:cdr_tm)
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
        physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
        physical_object.box = FactoryGirl.create(:box)
        physical_object.save!
        split_show
      end
      include_examples "rejects action"
    end
    context "on a binned object" do
      before(:each) do
        physical_object.format = "Open Reel Audio Tape"
        physical_object.ensure_tm.assign_attributes(FactoryGirl.attributes_for :open_reel_tm)
	      physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
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
	  physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
          physical_object.box = FactoryGirl.create(:box)
          physical_object.save!
        end
        include_examples "prevents split"
      end
      context "on a binned item" do
        before(:each) do
          physical_object.format = "Open Reel Audio Tape"
          physical_object.ensure_tm.assign_attributes(FactoryGirl.attributes_for :open_reel_tm)
	        physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
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
        physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
        physical_object.box = FactoryGirl.create(:box)
        physical_object.save!
      end
      include_examples "prevents split"
    end
    context "on a binned item" do
      let(:source_page) { "source_page" }
      before(:each) do
        physical_object.format = "Open Reel Audio Tape"
        physical_object.ensure_tm.assign_attributes(FactoryGirl.attributes_for :open_reel_tm)
	      physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
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
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
      end
    end
    describe "associating to a new picklist" do
      context "not providing a name" do
        before(:each) { post :upload_update, type: "new", picklist: {} }
        it "flashes a notice" do
          expect(flash[:notice]).to match /picklist.*name/
        end
        it "redirects to :back" do
          expect(response).to redirect_to 'source_page'
        end
      end
    end
    describe "without specifying a file" do
      before(:each) { post :upload_update, type: "none" }
      it "flashes a notice" do
        expect(flash[:notice]).to match /please.*specify.*file/i
      end
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
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

    ['po_import_1_half_inch_open_reel_video_tape.csv', 'po_import_1_inch_open_reel_video_tape.csv', 'po_import_audiocassette.csv', "po_import_betacam.csv", 'po_import_betamax.csv', "po_import_8mm.csv", "po_import_cdr.csv", "po_import_cdr_iso-8559-1.csv", "po_import_cdr.xlsx", "po_import_DAT.csv", "po_import_orat.csv", "po_import_lp.csv", "po_import_lacquer_disc.csv", "po_import_other_analog_sound_disc.csv", "po_import_umatic.csv", 'po_import_vhs.csv'].each do |filename|
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
        context "and an existing shipment" do
          before(:each) { post_args[:type] = "shipment" }
          describe "selected" do
            before(:each) do
              shipment
              post_args[:shipment] = { id: shipment.id }
            end
            include_examples "upload results", filename
            it "uses the selected picklist" do
              upload_update
              expect(assigns[:shipment]).to eq shipment
            end
          end
          describe "not selected" do
            before(:each) do
              post_args[:shipment] = {}
              upload_update
            end
            it "flashes inaction" do
              expect(flash[:notice]).to match /select.*shipment/i
            end
            it "redirects to :back" do
              expect(response).to redirect_to 'source_page'
            end
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
            it "redirects to :back" do
              expect(response).to redirect_to 'source_page'
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
            it "redirects to :back" do
              expect(response).to redirect_to 'source_page'
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
        physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
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
        physical_object.ensure_tm.assign_attributes(FactoryGirl.attributes_for :open_reel_tm)
	      physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
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
        physical_object.mdpi_barcode = BarcodeHelper.valid_mdpi_barcode
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
    let!(:original_group) { physical_object.group_key }
    let(:ungroup) {
      request.env["HTTP_REFERER"] = "source_page"
      post :ungroup, id: physical_object.id
    }
    it "removes the existing group key association" do
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
    context "when original group is now empty" do
      before(:each) do
        expect(original_group.physical_objects.size).to eq 1
      end
      specify "destroys the original group" do
        ungroup
        expect(GroupKey.where(id: original_group.id)).to be_empty
      end
      specify "redirects to physical object" do
        ungroup
        expect(response).to redirect_to physical_object
      end
    end
    context "when the original group is not empty" do
      before(:each) do
        grouped_object = FactoryGirl.create(:physical_object, :cdr, group_key: physical_object.group_key)
        original_group.reload
        expect(original_group.physical_objects.size).to eq 2
      end
      specify "does NOT destroy the original group" do
        ungroup
        expect(GroupKey.where(id: original_group.id)).not_to be_empty
      end
      it "redirects to :back" do
        ungroup
        expect(response).to redirect_to "source_page"
      end
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
    it "returns 'false' when ephemera not present (false)" do
      barcoded_object.has_ephemera = false
      barcoded_object.save!
      post_has_ephemera
      expect(response.body).to eq "false"
    end
    it "returns 'false' when ephemera not present (nil)" do
      barcoded_object.has_ephemera = nil
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

  describe "GET is_archived" do
    let(:get_is_archived) { get :is_archived, mdpi_barcode: barcoded_object.mdpi_barcode }
    it "returns 'true' when is archived" do
      barcoded_object.digital_statuses.create!(state: 'archived')
      get_is_archived
      expect(response.body).to eq "true"
    end
    it "returns 'false' isn't archived" do
      get_is_archived
      expect(response.body).to eq "false"
    end
    it "returns 'unknown physical Object' when physical object not found" do
      get :is_archived, mdpi_barcode: 1234
      expect(response.body).to eq "unknown physical Object"
    end
    it "returns 'unknown physical Object' when given a 0 barcode" do
      physical_object
      get :is_archived, mdpi_barcode: 0
      expect(response.body).to eq "unknown physical Object"
    end
  end

  describe "GET edit_ephemera" do
    before(:each) { get :edit_ephemera, id: physical_object.id }
    it "assigns the object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
    it "renders the template" do
      expect(response).to render_template :edit_ephemera
    end
  end

  describe "GET contained" do
    let(:included_date) { Time.now }
    let(:start_date) { included_date - 3.days }
    let(:end_date) { included_date + 3.days }
    let(:excluded_date) { start_date - 3.days }
    let(:uncontained_object) { FactoryGirl.create :physical_object, :barcoded, :boxable }
    let(:included_boxed_object) { FactoryGirl.create :physical_object, :barcoded, :boxable }
    let(:excluded_boxed_object) { FactoryGirl.create :physical_object, :barcoded, :boxable }
    let(:included_binned_object) { FactoryGirl.create :physical_object, :barcoded, :binnable }
    let(:excluded_binned_object) { FactoryGirl.create :physical_object, :barcoded, :binnable }
    let(:box) { FactoryGirl.create :box }
    let(:bin) { FactoryGirl.create :bin }
    let(:wst_ids) { WorkflowStatusTemplate.where(name: ['Binned', 'Boxed']).map(&:id) }
    before(:each) do
      uncontained_object
      included_boxed_object.box = box
      included_boxed_object.save!
      included_binned_object.bin = bin
      included_binned_object.save!
      excluded_boxed_object.box = box
      excluded_boxed_object.save!
      excluded_boxed_object.workflow_statuses.last.update_attributes!(created_at: excluded_date)
      excluded_binned_object.bin = bin
      excluded_binned_object.save!
      excluded_binned_object.workflow_statuses.last.update_attributes!(created_at: excluded_date)
    end
    context "basic functions" do
      before(:each) { get :contained, format: "xls" }
      it "sets @physical_objects" do
        expect(assigns(:physical_objects)).to respond_to :size
      end
      it "renders :contained template" do
        expect(response).to render_template :contained
      end
    end
    context "when missing start_date" do
      before(:each) { get :contained, format: "xls", physical_object: { workflow_status_template_id: wst_ids, end_date: end_date } }
      it "sets @physical_objects to empty" do
        expect(assigns(:physical_objects)).to be_empty
      end
    end
    context "when missing end_date" do
      before(:each) { get :contained, format: "xls", physical_object: { workflow_status_template_id: wst_ids, start_date: start_date } }
      it "sets @physical_objects to empty" do
        expect(assigns(:physical_objects)).to be_empty
      end
    end
    context "when providing valid start_date and end_date" do
      before(:each) { get :contained, format: "xls", physical_object: { workflow_status_template_id: wst_ids, start_date: start_date, end_date: end_date } }
      it "returns only physical_objects set to binned/boxed in provided date range" do
        expect(assigns(:physical_objects)).to include included_boxed_object
        expect(assigns(:physical_objects)).to include included_binned_object
        expect(assigns(:physical_objects)).not_to include uncontained_object
        expect(assigns(:physical_objects)).not_to include excluded_boxed_object
        expect(assigns(:physical_objects)).not_to include excluded_binned_object
      end
    end
  end

  describe "GET generate_filename" do
    let(:sequence) { 42 }
    let(:use) { "use" }
    let(:extension) { "ext" }
    before(:each) { get :generate_filename, id: physical_object.id, sequence: sequence, use: use, extension: extension }
    it "sets @physical_object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
    it "returns valid results" do
      expect(response.body).to match physical_object.generate_filename(sequence: sequence, use: use, extension: extension)
    end
  end

  describe "GET tm_form" do
    let(:params) { { format: 'CD-R' } }
    let(:get_tm_form) { get :tm_form, params }
    shared_examples "tm_form behaviors" do |object_type|
      context "search" do
        before(:each) { params[:id] = 0 }
        before(:each) { params[:search_mode] = 'true' }
        before(:each) { get_tm_form }
        it "assigns @search_mode" do
          expect(assigns(:search_mode)).to eq true
        end
        it "assigns new @#{object_type}" do
          expect(assigns(object_type)).to be_a_new object_class
        end
        it "assigns new @tm" do
          expect(assigns(:tm)).to be_a_new CdrTm
        end
        it "renders generic TM form" do
          expect(response).to render_template partial: 'technical_metadatum/_show_generic_tm'
        end
      end
      context "new" do
        before(:each) { params[:id] = 0 }
        before(:each) { get_tm_form }
        it "assigns new @#{object_type}" do
          expect(assigns(object_type)).to be_a_new object_class
        end
        it "assigns new @tm" do
          expect(assigns(:tm)).to be_a_new CdrTm
        end
        it "renders format-specific TM form" do
          expect(response).to render_template partial: 'technical_metadatum/_show_cdr_tm'
        end
      end
      context "existing" do
        before(:each) { params[:id] = existing_object.id }
        before(:each) { params[:edit_mode] = 'true' }
        before(:each) { get_tm_form }
        it "assigns @edit_mode" do
          expect(assigns(:edit_mode)).to eq true
        end
        it "assigns existing @#{object_type}" do
          expect(assigns(object_type)).to eq existing_object
        end
        it "assigns existing @tm" do
          expect(assigns(:tm)).to eq existing_object.technical_metadatum.specific
        end
        it "renders format-specific TM form" do
          expect(response).to render_template partial: 'technical_metadatum/_show_cdr_tm'
        end
      end
    end
    context "for Physical Object" do
      before(:each) { params[:type] = 'PhysicalObject' }
      let(:object_class) { PhysicalObject }
      let(:existing_object) { physical_object }
      include_examples "tm_form behaviors", :physical_object
    end
    context "for PicklistSpecification" do
      before(:each) { params[:type] = 'PicklistSpecification' }
      let(:object_class) { PicklistSpecification }
      let(:existing_object) { picklist_specification }
      include_examples "tm_form behaviors", :picklist_specification
    end

  end
end
