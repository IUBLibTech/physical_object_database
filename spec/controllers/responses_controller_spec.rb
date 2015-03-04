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
      get :metadata, mdpi_barcode: 0
      expect(response).to have_http_status(200)
    end
    it "returns 401 status on an action if not authenticated" do
      invalid_auth
      get :metadata, mdpi_barcode: 0
      expect(response).to have_http_status(401)
    end
  end

  describe "#metadata" do
    context "with a valid barcode" do
      before(:each) { get :metadata, mdpi_barcode: barcoded_object.mdpi_barcode }
      it "assigns @physical_object" do
        expect(assigns(:physical_object)).to eq barcoded_object
      end
      it "returns success=true XML" do
        expect(response.body).to match /<success.*true<\/success>/
      end
      it "returns data XML" do
        expect(response.body).to match /<data>/
        expect(response.body).to match /<format>#{physical_object.format}<\/format>/
        expect(response.body).to match /<files>#{physical_object.technical_metadatum.master_copies}<\/files>/
      end
      it "returns a 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    shared_examples "finds no object" do
      it "assigns @physical_object to nil" do
        expect(assigns(:physical_object)).to be_nil
      end
      it "returns failture XML" do
        expect(response.body).to match /<success>false/
      end
      it "returns failure message XML" do
        expect(response.body).to match /<message>MDPI Barcode.*(does not exist|cannot be 0)/
      end
      it "returns a 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    context "with a 0 barcode" do
      before(:each) { get :metadata, mdpi_barcode: physical_object.mdpi_barcode }
      include_examples "finds no object"
    end
    context "with an unmatched barcode" do
      before(:each) { get :metadata, mdpi_barcode: 1234 }
      include_examples "finds no object"
    end
  end

  describe "#notify" do
    before(:each) { post :notify, request_xml, content_type: 'application/xml' }
    let(:request_xml) { "<pod><data><message>#{message_text}</message></data></pod>" }
    context "with message text" do
      let(:message_text) { "Hello world" }
      it "creates a notification message" do
        expect(assigns(:message)).to be_persisted
        expect(assigns(:message).content).to eq message_text
        expect(Message.first).not_to be_nil
      end
      it "returns success XML" do
        expect(response.body).to match /<success>true/
      end
      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    context "without message text" do
      let(:message_text) { "" }
      it "does not create a notification message" do
        expect(assigns(:message)).not_to be_persisted
        expect(Message.first).to be_nil
      end
      it "returns failure xml" do
        expect(response.body).to match /<success>false/
      end
      it "returns 400 status" do
        expect(response).to have_http_status(400)
      end
    end
  end

  describe "#push_status" do
    let!(:po) { FactoryGirl.create( :physical_object, :cdr, :barcoded) }
    #FIXME: deprecate
    let!(:jh) { 
      {
        mdpi_barcode: po.mdpi_barcode, 
        #FIXME: receive state?
        state: "failed", 
        attention: true, 
        messsage: "some message about the error", 
        options: {
          accept: "Retry processing",
          investigate: "Manually investigate data storage for what went wrong",
          to_delete: "Discard this object and redigitize or re-upload it"
        }
      }
    }

    context "missing xml" do
      before(:each) do
       post :push_status, mdpi_barcode: po.mdpi_barcode, content_type: 'application/xml'
      end
      pending "FIXME: digital status objects need validations before an invalid request can be made..." do
        it "renders failure XML" do
          expect(response.body).to match /<success>false/
        end
        it "renders failure message" do
          expect(response.body).to match /<message>/
        end
        it "returns bad request status" do
          expect(response).to have_http_status(400)
        end
      end
    end
    
    context "invalid xml" do
      pending "FIXME: test sending XML insufficient to create a valid digital status"
    end

    context "valid xml" do
      let(:request_xml) {
"     <pod>
        <data>
          <message>some message about the error</message>
          <attention>true</attention>
          <options>
            <option>
              <state>accept</state>
              <description>Retry processing</description>
             </option>
            <option>
              <state>investigate</state>
              <description>Manually investigate data storage for what went wrong</description>
             </option>
            <option>
              <state>to_delete</state>
              <description>Discard this object and redigitize or re-upload it</description>
             </option>
          </options>
        </data>
      </pod>"
      }
      before(:each) do
        expect(po.digital_statuses).to be_empty
        post :push_status, request_xml, mdpi_barcode: po.mdpi_barcode, content_type: 'application/xml'
      end
      it "creates a digital status" do
        expect(po.digital_statuses.size).to eq 1
      end
      it "renders success XML" do
        expect(response.body).to match /<success>true/
      end
      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "#pull_state" do
    let!(:po) { FactoryGirl.create( :physical_object, :cdr, :barcoded) }
    context "physical object has no digital statuses" do
      before(:each) do
        expect(po.digital_statuses.size).to eq 0
        get :pull_state, mdpi_barcode: po.mdpi_barcode
      end
      it "returns failure XML" do
        expect(response.body).to match /<success>false/
      end
      it "returns a failure message" do
        expect(response.body).to match /<message>Physical Object.*0.*Statuses/i
      end
      it "returns 400 status" do
        expect(response).to have_http_status(400)
      end
    end
    context "physical object has digital status but no decision" do
      let!(:ds) { FactoryGirl.create :digital_status, physical_object_id: po.id, physical_object_mdpi_barcode: po.mdpi_barcode} 
      before(:each) do
        expect(ds.decided).to be_nil
        get :pull_state, mdpi_barcode: po.mdpi_barcode
      end
      it "returns success XML" do
        expect(response.body).to match /<success>true/
      end
      it "returns a blank state" do
        expect(response.body).to match /<state\/>/
      end
      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    context "physical object has digital status and decision" do
      let!(:ds) { FactoryGirl.create :digital_status, physical_object_id: po.id, physical_object_mdpi_barcode: po.mdpi_barcode }
      before(:each) do
        ds.decided = ds.options.keys[0].to_s
        ds.save
        get :pull_state, mdpi_barcode: po.mdpi_barcode
      end
      it "returns success XML" do
        expect(response.body).to match /<success>true/
      end
      it "returns a determined state" do
        expect(response.body).to match /<state>.*<\/state>/
      end
      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end

  end

end
