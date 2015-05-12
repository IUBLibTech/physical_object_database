require 'rails_helper'

describe ReturnsController do
  render_views
  before(:each) { sign_in }
  let(:batch) { FactoryGirl.create :batch, identifier: "Created Batch" }
  let(:created_batch) { FactoryGirl.create :batch, identifier: "Returned Batch" }
  let(:bin) { FactoryGirl.create :bin, batch: batch }
  let(:box) { FactoryGirl.create :box, bin: bin }
  let(:physical_object) { FactoryGirl.create :physical_object, :binnable, bin: bin }

  before(:each) do
    batch.current_workflow_status = "Returned"
    batch.save
  end

  describe "GET index (on collection)" do
    before(:each) do
      batch.save
      created_batch.save
      get :index 
    end
    it "assigns @batches to Returned batches" do
      expect(assigns(:batches)).to eq [batch]
    end
    it "renders the :index view" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET return_bins (on member)" do
    before(:each) do
      batch.save
      bin.save
      get :return_bins, id: batch.id
    end
    it "assigns @batch" do
      expect(assigns(:batch)).to eq batch
    end
    it "assigns @bins" do
      expect(assigns(:bins)).to eq batch.bins
    end
    it "renders the :return_bins view" do
      expect(response).to render_template(:return_bins)
    end
  end

  describe "GET return_bin (on member)" do
    shared_examples "return_bin behavior" do
      it "assigns @bin" do
        expect(assigns(:bin)).to eq bin
      end
      it "assigns @returned as Unpacked, Returned to Unit objects in bin" do
        expect(assigns(:returned).sort).to eq [unpacked_object, returned_object].sort
      end
      it "assigns @shipped as Binned objects in bin" do
        expect(assigns(:shipped)).to eq [shipped_object]
      end
      it "renders the :return_bin view" do
        expect(response).to render_template(:return_bin)
      end
    end
    context "on binned objects" do
      let(:shipped_object) { FactoryGirl.create :physical_object, :binnable, bin: bin }
      let(:unpacked_object) { FactoryGirl.create :physical_object, :binnable, bin: bin }
      let(:returned_object) { FactoryGirl.create :physical_object, :binnable, bin: bin }
      before(:each) do
        batch.save
        bin.save
        shipped_object.save
        unpacked_object.current_workflow_status = "Unpacked"
        unpacked_object.save
        returned_object.current_workflow_status = "Returned to Unit"
        returned_object.save
        get :return_bin, id: bin.id
      end
      include_examples "return_bin behavior"
    end
    context "on boxed objects" do
      let(:shipped_object) { FactoryGirl.create :physical_object, :boxable, box: box }
      let(:unpacked_object) { FactoryGirl.create :physical_object, :boxable, box: box }
      let(:returned_object) { FactoryGirl.create :physical_object, :boxable, box: box }
      before(:each) do
        batch.save
        bin.save
	box.save
        shipped_object.save
        unpacked_object.current_workflow_status = "Unpacked"
        unpacked_object.save
        returned_object.current_workflow_status = "Returned to Unit"
        returned_object.save
        get :return_bin, id: bin.id
      end
      include_examples "return_bin behavior"
    end
  end

  describe "PATCH unload_bin (on member)" do
    let(:patch_action) { patch :unload_bin, id: bin.id }
    before(:each) { request.env["HTTP_REFERER"] = "source_page" }
    context "on an unbatched bin" do
      before(:each) do
        bin.batch = nil
        bin.save
        patch_action
      end
      it "flashes an inaction warning" do
        expect(flash[:warning]).to match /not associated.*batch/
      end
      it "redirects to :back" do
        expect(response).to redirect_to "source_page"
      end
    end
    context "on an unloaded bin" do
      ["Returned to Staging Area", "Unpacked"].each do |status|
        context "in #{status} status" do
          before(:each) do
            bin.current_workflow_status = status
            bin.save
            patch_action
          end
          it "flashes an inaction message" do
            expect(flash[:notice]).to match /already.*unloaded/
          end
          it "redirects to :back" do
            expect(response).to redirect_to "source_page"
          end
        end
      end
    end
    context "on a loaded bin" do
      before(:each) do
        patch_action
      end
      it "sets the bin workflow status to Returned to Staging Area" do
        expect(bin.current_workflow_status).to eq "Batched"
        bin.reload
        expect(bin.current_workflow_status).to eq "Returned to Staging Area"
      end
      it "flashes a success message" do
        expect(flash[:notice]).to match /success/
      end
      it "redirects to :back" do
        expect(response).to redirect_to "source_page"
      end
    end
  end

  describe "GET physical_object_missing (on member) -- no action?" do
    skip "No action defined?  and no template rendered?"
  end

  describe "PATCH physical_object_returned (on member)" do
    let(:patch_action) { patch :physical_object_returned, id: bin.id, mdpi_barcode: physical_object.mdpi_barcode, ephemera_returned: { ephemera_returned: 0 } }
    context "physical object not found" do
      before(:each) do
        patch :physical_object_returned, id: bin.id, mdpi_barcode: '1234'
      end
      it "flashes a 'not found' warning" do
        expect(flash[:warning]).to match /No Physical Object.*was found/
      end
      it "redirects to return_bin action" do
        expect(response).to redirect_to return_bin_return_path(bin.id)
      end
    end
    context "physical object not associated to bin" do
      before(:each) do
        bin.save
        physical_object.bin = nil
        physical_object.save
        patch_action
      end
      it "flashes a 'not originally shipped with this bin' warning" do
        expect(flash[:warning]).to match /not originally shipped.*with this bin/
      end
      it "redirects to return_bin action" do
        expect(response).to redirect_to return_bin_return_path(bin.id)
      end
    end
    context "physical object associated to different bin" do
      before(:each) do
        bin.save
        physical_object.bin = FactoryGirl.create :bin, identifier: "other bin"
        physical_object.save
        patch_action
      end
      it "flashes a 'not originally shipped with this bin' warning" do
        expect(flash[:warning]).to match /not originally shipped.*with this bin/
      end
      it "redirects to return_bin action" do
        expect(response).to redirect_to return_bin_return_path(bin.id)
      end
    end
    context "physical object associated to bin" do
      context "already returned" do
        before(:each) do
	  physical_object.current_workflow_status = "Unpacked"
	  physical_object.save
	  patch_action
        end
        it "flashes an inaction notice" do
          expect(flash[:notice]).to match /already.*returned/
        end
        it "redirects to return_bin action" do
          expect(response).to redirect_to return_bin_return_path(bin.id)
        end
      end
      context "without ephemera" do
        before(:each) do
          physical_object.has_ephemera = false
          physical_object.save
          patch_action
        end
        it "assigns @bin" do
          expect(assigns(:bin)).to eq bin
        end
        it "updates the workflow status" do
          expect(physical_object.current_workflow_status).not_to eq "Unpacked"
          physical_object.reload
          expect(physical_object.current_workflow_status).to eq "Unpacked"
        end
        it "sets ephemera_returned field to false" do
          physical_object.reload
          expect(physical_object.ephemera_returned).to be false
        end
        it "flashes a success message" do
          expect(flash[:notice]).to match /Physical Object.*was successfully returned/
        end
        it "redirects to return_bin action" do
          expect(response).to redirect_to return_bin_return_path(bin.id)
        end
      end
      context "with ephemera, returned" do
        before(:each) do
          physical_object.has_ephemera = true
          physical_object.save
          patch :physical_object_returned, id: bin.id, mdpi_barcode: physical_object.mdpi_barcode, ephemera_returned: { ephemera_returned: 1 }
        end
        it "assigns @bin" do
          expect(assigns(:bin)).to eq bin
        end
        it "updates the workflow status to Unpacked" do
          physical_object.reload
          expect(physical_object.current_workflow_status).to eq "Unpacked"
        end
        it "updates the ephemera returned field" do
          physical_object.reload
          expect(physical_object.ephemera_returned).to be true
        end
        it "flashes a success message" do
          expect(flash[:notice]).to match /Physical Object.*was successfully returned/
        end
        it "flashes an 'ephemera returned' message" do
          expect(flash[:notice]).to match /ephemera was also returned/
        end
        it "redirects to return_bin action" do
          expect(response).to redirect_to return_bin_return_path(bin.id)
        end
      end
      context "with ephemera, not returned" do
        before(:each) do
          physical_object.has_ephemera = true
          physical_object.save
          patch_action
        end
        it "assigns @bin" do
          expect(assigns(:bin)).to eq bin
        end
        it "updates the workflow status to Unpacked" do
          physical_object.reload
          expect(physical_object.current_workflow_status).to eq "Unpacked"
        end
        it "updates the ephemera returned field" do
          physical_object.reload
          expect(physical_object.ephemera_returned).to be false
        end
        it "flashes a success message" do
          expect(flash[:notice]).to match /Physical Object.*was successfully returned/
        end
        it "flashes an 'ephemera NOT returned' message" do
          expect(flash[:notice]).to match /ephemera was NOT returned/
        end
        it "redirects to return_bin action" do
          expect(response).to redirect_to return_bin_return_path(bin.id)
        end
      end
    end
  end

  describe "PATCH batch_complete (on member)" do
    let(:patch_action) { patch :batch_complete, id: batch.id }
    context "on a batch already Complete" do
      before(:each) do
        batch.current_workflow_status = "Complete"
        batch.save
        patch_action
      end
      it "flashes 'No action taken' notice" do
        expect(flash[:notice]).to match /No action taken/
      end
      it "redirects to returns_path" do
        expect(response).to redirect_to returns_path
      end
    end
    context "with all bins Unpacked" do
      before(:each) do
        bin.current_workflow_status = "Unpacked"
        bin.save
        batch.current_workflow_status = "Returned"
        batch.save
        patch_action
      end
      it "updates the batch status to Complete" do
        expect(batch.current_workflow_status).not_to eq "Complete"
        batch.reload
        expect(batch.current_workflow_status).to eq "Complete"
      end
      it "flashes a success notice" do
        expect(flash[:notice]).to match /success/
      end
      it "redirects to returns_path" do
        expect(response).to redirect_to returns_path
      end
    end
    context "with NOT all bins Unpacked" do
      before(:each) do
        bin.save
        batch.current_workflow_status = "Returned"
        batch.save
        patch_action
      end
      it "flashes a failure warning" do
        expect(flash[:warning]).to match /cannot be.*Complete/
      end
      it "redirects to return_bins action" do
        expect(response).to redirect_to return_bins_return_path(batch.id)
      end
    end
  end

  describe "PATCH bin_unpacked (on member)" do
    let(:patch_action) { patch :bin_unpacked, id: bin.id }
    context "on a Bin not yet Returned to Staging Area" do
      before(:each) do
        patch_action
      end
      it "flashes inaction warning" do
        expect(flash[:warning]).to match /cannot be/
      end
      it "redirects to return_bins action for batch" do
        expect(response).to redirect_to return_bins_return_path(bin.batch.id)
      end
    end
    context "on a Bin Unpacked (already)" do
      before(:each) do
        bin.current_workflow_status = "Unpacked"
        bin.save
        patch_action
      end
      it "flashes inaction message" do
        expect(flash[:notice]).to match /No action taken/
      end
      it "redirects to return_bins action for batch" do
        expect(response).to redirect_to return_bins_return_path(bin.batch.id)
      end
    end
    context "on a Bin Returned to Staging Area" do
      before(:each) do
        bin.current_workflow_status = "Returned to Staging Area"
        bin.save
      end
      context "all objects Unpacked" do
        before(:each) do
          physical_object.current_workflow_status = "Unpacked"
          physical_object.save
          patch_action
        end
        it "assigns @bin" do
          expect(assigns(:bin)).to eq bin
        end
        it "updates bin workflow status to Unpacked" do
          bin.reload
          expect(bin.current_workflow_status).to eq "Unpacked"
        end
        it "redirects to return_bins action for batch" do
          expect(response).to redirect_to return_bins_return_path(bin.batch.id)
        end
      end
      context "not all objects Unpacked" do
        context "remainder unprocessed" do
          before(:each) do
            physical_object.save
            patch_action
          end
          it "assigns @bin" do
            expect(assigns(:bin)).to eq bin
          end
          it "flashes a warning" do
            expect(flash[:warning]).not_to be_blank
          end
          it "redirects to return_bin action for bin" do
            expect(response).to redirect_to return_bin_return_path(bin.id)
          end
        end
        context "remainder marked Missing (inactive)" do
          before(:each) do
            FactoryGirl.create :condition_status, physical_object: physical_object, condition_status_template_id: ConditionStatusTemplate.find_by(object_type: "Physical Object", name: "Missing").id, active: false
            patch_action
          end
          it "assigns @bin" do
            expect(assigns(:bin)).to eq bin
          end
          it "flashes a warning" do
            expect(flash[:warning]).not_to be_blank
          end
          it "redirects to return_bin action for bin" do
            expect(response).to redirect_to return_bin_return_path(bin.id)
          end
        end
        context "remainder marked Missing (active)" do
          before(:each) do
            FactoryGirl.create :condition_status, physical_object: physical_object, condition_status_template_id: ConditionStatusTemplate.find_by(object_type: "Physical Object", name: "Missing").id
            patch_action
          end
          it "assigns @bin" do
            expect(assigns(:bin)).to eq bin
          end
          # FIXME: add Bin condition?
          it "updates bin workflow status to Unpacked" do
            expect(bin.current_workflow_status).not_to eq "Unpacked"
            bin.reload
            expect(bin.current_workflow_status).to eq "Unpacked"
          end
          it "redirects to return_bins action for batch" do
            expect(response).to redirect_to return_bins_return_path(bin.batch.id)
          end
        end
      end
    end
  end

end
