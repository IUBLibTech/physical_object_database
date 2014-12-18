require 'rails_helper'

describe BatchesController do
  render_views
  before(:each) { sign_in }
  let(:batch) { FactoryGirl.create(:batch) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:valid_batch) { FactoryGirl.build(:batch) }
  let(:invalid_batch) { FactoryGirl.build(:invalid_batch) }

  describe "GET index" do
    before(:each) do
      batch.save
      get :index
    end
    it "populates an array of objects" do
      expect(assigns(:batches)).to eq [batch]
    end
    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: batch.id }

    it "assigns the requested object to @batch" do
      expect(assigns(:batch)).to eq batch
    end
      
    it "renders the :show template" do
      expect(response).to render_template(:show)
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

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, batch: valid_batch.attributes.symbolize_keys }
      it "saves the new object in the database" do
        expect{ creation }.to change(Batch, :count).by(1)
      end
      it "redirects to the objects index" do
        creation
        expect(response).to redirect_to(controller: :batches, action: :index) 
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
      it "re-renders the :show template" do
        expect(response).to render_template(:show)
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

end
