describe BatchesController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
  let(:batch) { FactoryGirl.create(:batch) }
  let(:returned) { FactoryGirl.create(:batch, identifier: 'returned', current_workflow_status: 'Returned', format: TechnicalMetadatumModule.box_formats.first) }
  let(:bin) { FactoryGirl.create(:bin, identifier: "bin") }
  let(:batched_bin) { FactoryGirl.create(:bin, identifier: "batched_bin", batch: batch) }
  let(:binned_box) { FactoryGirl.create(:box, bin: batched_bin) }
  let(:po_dat) { FactoryGirl.create(:physical_object, :barcoded, :dat, box: binned_box, digital_start: Time.now) }
  let(:valid_batch) { FactoryGirl.build(:batch) }
  let(:invalid_batch) { FactoryGirl.build(:invalid_batch) }

  describe "GET index" do
    context "with no filters" do
      before(:each) do
        batch
        get :index
      end
      it "assigns @batches empty" do
        expect(assigns(:batches)).to be_empty
      end
      it 'renders :index' do
        expect(response).to render_template :index
      end
    end
    context "with empty filters" do
      before(:each) do
        batch
        get :index, format: format, workflow_status: ''
      end
      shared_examples "index behaviors" do
        it "populates an array of objects" do
          expect(assigns(:batches)).to eq [batch]
        end
        it "assigns @now" do
          expect(assigns(:now)).to be_a Time
        end
        it "assigns @future" do
          expect(assigns(:future)).to be_a Time
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
    describe "identifier filter" do
      before(:each) do
        batch; returned
        get :index, identifier: identifier
      end
      context "with blank value set" do
        let(:identifier) { '' }
        it "returns all batches" do
          expect(assigns(:batches).sort).to eq [batch, returned].sort
        end
      end
      context "with a matching value set" do
        let(:identifier) { returned.identifier[0, (returned.identifier.size - 1)] }
        it "returns matching batches" do
          expect(assigns(:batches)).to eq [returned]
        end
      end
      context "with a non-matching value set" do
        let(:identifier) { "non-matching value" }
        it "returns no batches" do
          expect(assigns(:batches)).to be_empty
        end
      end
    end
    describe "workflow status filter" do
      before(:each) do
        batch; returned
        get :index, workflow_status: workflow_status
      end
      context "with blank value set" do
        let(:workflow_status) { '' }
        it "returns all batches" do
          expect(assigns(:batches).sort).to eq [batch, returned].sort
        end
      end
      context "with a matching value set" do
        let(:workflow_status) { returned.workflow_status }
        it "returns matching batches" do
          expect(assigns(:batches)).to eq [returned]
        end
      end
      context "with a non-matching value set" do
        let(:workflow_status) { "non-matching value" }
        it "returns no batches" do
          expect(assigns(:batches)).to be_empty
        end
      end
    end
    describe "format filter" do
      before(:each) do
        batch; returned
        get :index, tm_format: format
      end
      context "with blank value set" do
        let(:format) { '' }
        it "returns all batches" do
          expect(assigns(:batches).sort).to eq [batch, returned ].sort
        end
      end
      context "with a matching value set" do
        let(:format) { returned.format }
        it "returns matching batches" do
          expect(assigns(:batches)).to eq [returned]
        end
      end
      context "with a non-matching value set" do
        let(:format) { "non-matching value" }
        it "returns no batches" do
          expect(assigns(:batches)).to be_empty
        end
      end
    end
  end
 
  describe "GET show" do
    before(:each) { bin; po_dat }
    context "in HTML format" do
      let!(:other_batch) { FactoryGirl.create(:batch, identifier: "other_batch") }
      let!(:unavailable_mismatched_bin) { FactoryGirl.create(:bin, identifier: "unavailable_mismatched_bin", batch: other_batch) }
      let!(:unavailable_mismatched_po) { FactoryGirl.create(:physical_object, :barcoded, :binnable, bin: unavailable_mismatched_bin) }
      let!(:available_matched_bin) { FactoryGirl.create(:bin, identifier: "available_matched_bin") }
      let!(:available_matched_box) { FactoryGirl.create(:box, bin: available_matched_bin) }
      let!(:available_matched_po) { FactoryGirl.create(:physical_object, :barcoded, :dat, box: available_matched_box) }
      let!(:available_mismatched_bin) { FactoryGirl.create(:bin, identifier: "available_mismatched_bin") }
      let!(:available_mismatched_po) { FactoryGirl.create(:physical_object, :barcoded, :binnable, bin: available_mismatched_bin) }
      before(:each) { get :show, id: batch.id }
      it "assigns the requested object to @batch" do
        expect(assigns(:batch)).to eq batch
      end
      it "assigns @digitization_start" do
        expect(assigns(:digitization_start)).not_to be_nil
        expect(assigns(:digitization_start)).to eq batch.digitization_start
      end
      it "assigns @auto_accept" do
        expect(assigns(:auto_accept)).not_to be_nil
        expect(assigns(:auto_accept)).to eq batch.auto_accept
      end
      it "assigns bins" do
        expect(assigns(:bins)).to eq [batched_bin]
      end
      it "assigns available_bins (unbatched, format match)" do
        expect(assigns(:available_bins).sort).to eq [available_matched_bin].sort
      end
      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
    end
    context "in XLS format" do
      before(:each) { get :show, id: "batch_#{batch.id}.xls", format: "xls" }
      it "assigns the requested object to @batch" do
        expect(assigns(:batch)).to eq batch
      end
      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
    end
  end

  describe "GET new" do
    before(:each) { get :new }
    it "assigns a new object to @batch" do
      expect(assigns(:batch)).to be_a_new(Batch)
    end
    it "renders the :new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: batch.id }
    it "locates the requested object" do
      expect(assigns(:batch)).to eq batch
    end
    it "renders the :edit template" do
      expect(response).to render_template(:edit) 
    end
  end

  describe "GET workflow_history" do
    before(:each) { get :workflow_history, id: batch.id }

    it "assigns the requested batch to @batch" do
      expect(assigns(:batch)).to eq batch
    end

    it "assigns the worfklow history to @workflow_statuses" do
      expect(assigns(:workflow_statuses)).to eq batch.workflow_statuses
    end

    it "renders the :workflow_history template" do
      expect(response).to render_template(:workflow_history)
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, batch: valid_batch.attributes.symbolize_keys }
      it "saves the new object in the database" do
        expect{ creation }.to change(Batch, :count).by(1)
      end
      it "redirects to the created object" do
        creation
        expect(response).to redirect_to assigns(:batch)
      end
    end

    context "with invalid attributes" do
      let(:creation) { post :create, batch: invalid_batch.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "does not save the new object in the database" do
        batch
	expect{ creation }.not_to change(Batch, :count)
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
        put :update, id: batch.id, batch: FactoryGirl.attributes_for(:batch, identifier: "Updated Test Batch")
      end

      it "locates the requested object" do
        expect(assigns(:batch)).to eq batch
      end
      it "changes the object's attributes" do
	expect(batch.identifier).not_to eq "Updated Test Batch"
        batch.reload
	expect(batch.identifier).to eq "Updated Test Batch"
      end
      it "redirects to the updated object" do
        expect(response).to redirect_to(action: :show) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: batch.id, batch: FactoryGirl.attributes_for(:invalid_batch)
      end

      it "locates the requested object" do
        expect(assigns(:batch)).to eq batch
      end
      it "does not change the object's attributes" do
        expect(batch.identifier).to eq "Test Batch"
        batch.reload
        expect(batch.identifier).to eq "Test Batch"
      end
      it "re-renders the :edit template" do
        expect(response).to render_template(:edit)
      end

    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: batch.id }
    it "deletes the object" do
      batch
      expect{ deletion }.to change(Batch, :count).by(-1)
    end
    it "redirects to the object index" do
      deletion
      expect(response).to redirect_to batches_path
    end
    it "resets bins workflow status to Sealed" do
      expect(batched_bin.workflow_status).to eq "Batched"
      deletion
      batched_bin.reload
      expect(batched_bin.workflow_status).to eq "Sealed"
    end
  end

  describe "PATCH add_bin" do
    context "specifying one or more bin_ids" do
      let(:add_bin) { patch :add_bin, id: batch.id, bin_ids: [bin.id]; bin.reload }
      context "on a Created bin" do
        it "adds bins to batch" do
          expect(bin.batch_id).to be_nil
          add_bin
          expect(bin.batch_id).to eq batch.id
        end
        it "sets added bins with a workflow status of Batched" do
          expect(bin.current_workflow_status).not_to eq "Batched"
          add_bin
          expect(bin.current_workflow_status).to eq "Batched"
        end
	it "flashes a success notice" do
          add_bin
	  expect(flash[:notice]).to match /success/
	end
	it "redirects to show" do
          add_bin
	  expect(response).to redirect_to batch
	end
      end
      context "on other statuses" do
        before(:each) do
	  batch.current_workflow_status = "Assigned"
	  batch.save
	  batch.reload
        end
        it "does NOT add bins to batch" do
          expect(bin.batch_id).to be_nil
          add_bin
          expect(bin.batch_id).to be_nil
        end
        it "bins do NOT get a workflow status of Batched" do
          expect(bin.current_workflow_status).not_to eq "Batched"
          add_bin
          expect(bin.current_workflow_status).not_to eq "Batched"
        end
        it "flashes a 'cannot' warning" do
          add_bin
          expect(flash[:warning]).to match /cannot.*assign/
        end
        it "redirects to show" do
          add_bin
          expect(response).to redirect_to batch
        end
      end
    end
    context "without selecting any bins" do
      let(:add_bin) { patch :add_bin, id: batch.id }
      it "flashes an inaction message" do
        add_bin
        expect(flash[:notice]).to match /No bins were selected/
      end
      it "redirects to show" do
        add_bin
        expect(response).to redirect_to batch
      end
    end
  end

  describe "GET list_bins" do
    before(:each) { get :list_bins, id: batch.id }
    it "assigns the requested object to @batch" do
      expect(assigns(:batch)).to eq batch
    end
    it "renders the :list_bins template" do
      expect(response).to render_template(:list_bins)
    end
  end

  describe "PATCH archived_to_picklist" do
    context "without a picklist specified" do
      before(:each) { patch :archived_to_picklist, id: batch.id }
      it "flashes a failure warnign" do
        expect(flash[:warning]).to match /not/i
      end
      it "redirects to :back" do
        expect(response).to redirect_to 'source_page'
      end
    end
    context "with a picklist specified" do
      let(:picklist) { FactoryGirl.create(:picklist) }
      let(:archived) { FactoryGirl.create(:physical_object, :binnable, :barcoded, bin: bin) }
      let(:unarchived) { FactoryGirl.create(:physical_object, :binnable, :barcoded, bin: bin) }
      before(:each) do
        unarchived
        archived.digital_statuses.create!(state: 'archived')
        bin.batch = batch; bin.save!
        patch :archived_to_picklist, id: batch.id, picklist: { id: picklist.id }
      end
      it "puts Archived objects on the picklist" do
        picklist.reload
        expect(picklist.physical_objects).not_to include unarchived
        expect(picklist.physical_objects).to include archived
      end
      it "flashes a success notice" do
        expect(flash[:notice]).to match /success/i
      end
      it "redirects to picklist" do
        expect(response).to redirect_to picklist
      end
    end
  end

end
