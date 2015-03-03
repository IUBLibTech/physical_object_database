require "rails_helper"
require 'ruby-debug'

describe ResponsesController do
  render_views
  # use BasicAuth instead of CAS
  before(:each) do
    basic_auth
  end
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }
  let(:barcoded_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }

  describe "requires BasicAuth" do
    it "returns 200 status on an action if authenticated" do
      get :metadata, barcode: 0
      expect(response).to have_http_status(200)
    end
    it "returns 401 status on an action if not authenticated" do
      invalid_auth
      get :metadata, barcode: 0
      expect(response).to have_http_status(401)
    end
  end

  describe "#metadata" do
    context "with a valid barcode" do
      before(:each) { get :metadata, barcode: barcoded_object.mdpi_barcode }
      it "assigns @physical_object" do
        expect(assigns(:physical_object)).to eq barcoded_object
      end
      it "returns found=true XML" do
        expect(response.body).to match /<found.*true<\/found>/
      end
      it "returns a 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    shared_examples "finds no object" do
      it "assigns @physical_object to nil" do
        expect(assigns(:physical_object)).to be_nil
      end
      it "returns found=false" do
        expect(response.body).to match /<found.*false<\/found>/
      end
      it "returns a 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    context "with a 0 barcode" do
      before(:each) { get :metadata, barcode: physical_object.mdpi_barcode }
      include_examples "finds no object"
    end
    context "with an unmatched barcode" do
      before(:each) { get :metadata, barcode: 1234 }
      include_examples "finds no object"
    end
  end

  describe "push_status" do
    let!(:po) { FactoryGirl.create( :physical_object, :cdr, :barcoded) }
    let!(:jh) { 
      {
        barcode: po.mdpi_barcode, 
        state: "failed", 
        attention: true, 
        messsage: "some message about the error", 
        options: {
          accept: "Retry processing",
          inverstigate: "Manually investigate data storage for what went wrong",
          to_delete: "Discard this object and redigitize or re-upload it"
        }
      }
    }
    let(:valid_json) {jh.to_json}
    let(:missing_barcode) {jh.except(:barcode).to_json}
    let(:unparsable_json) {jh.to_json.sub("\"", "'")}

    context "missing json" do
      before(:each) do
       get :push_status
      end
      it "returns bad request status" do
        expect(response).to have_http_status(400)
      end
    end

    context "valid json" do
      before(:each) do
        expect(po.digital_statuses).to be_empty
        get :push_status, json: valid_json
      end
      it "accepts the status change" do
        expect(response).to have_http_status(200)
        expect(po.digital_statuses.size).to eq 1
      end
    end
    
    context "missing barcode" do
      before(:each) do
        expect(po.digital_statuses).to be_empty
        get :push_status, json: missing_barcode
      end
      it "returns bad request status" do
        expect(response).to have_http_status(400)
      end
    end
  end

  describe "pull_state" do
    let!(:po) { FactoryGirl.create( :physical_object, :cdr, :barcoded) }
    let!(:jh) { 
      {
        barcode: po.mdpi_barcode, 
        state: "failed", 
        attention: true, 
        messsage: "some message about the error", 
        options: {
          accept: "Retry processing",
          inverstigate: "Manually investigate data storage for what went wrong",
          to_delete: "Discard this object and redigitize or re-upload it"
        }
      }
    }

    context "physical object has no digital statuses" do
      before(:each) do
        expect(po.digital_statuses.size).to eq 0
        get :pull_state, barcode: po.mdpi_barcode
      end
      it "cannot pull a state request" do
        expect(assigns(:status)).to eq 400
        expect(assigns(:message)).to include("has 0 Digital Statuses")
      end
    end

    context "physical object has digital status but no decision" do
      let!(:ds) { FactoryGirl.create :digital_status, physical_object_id: po.id, physical_object_mdpi_barcode: po.mdpi_barcode} 
      before(:each) do
        expect(ds.decided).to be_nil
        get :pull_state, barcode: po.mdpi_barcode
      end

      it "returns null for decision" do
        expect(assigns(:status)).to eq 200
        expect(assigns(:message)).to eq nil
      end
    end

    context "physical object has digital status and decision" do
      let!(:ds) { FactoryGirl.create :digital_status, physical_object_id: po.id, physical_object_mdpi_barcode: po.mdpi_barcode }
      before(:each) do
        ds.decided = ds.options.keys[0].to_s
        ds.save
        get :pull_state, barcode: po.mdpi_barcode
      end

      it "returns an option" do
        puts ds.inspect
        expect(assigns(:status)).to eq 200
        expect(assigns(:message)).to eq ds.decided      
      end

    end

  end

end
