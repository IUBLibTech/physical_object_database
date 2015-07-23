require "rails_helper"
require 'debugger'

describe ResponsesController do
  render_views
  # use BasicAuth instead of CAS
  before(:each) do
    basic_auth
  end
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }
  let(:barcoded_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }
  let!(:unmatched_barcode) { 1234 }

  describe "requires BasicAuth" do
    # as this is applied to the entire controller, we'll just test one call
    it "returns 200 status on an action if authenticated" do
      get :metadata, mdpi_barcode: barcoded_object.mdpi_barcode
      expect(response).to have_http_status(200)
    end
    it "returns 401 status on an action if not authenticated" do
      invalid_auth
      get :metadata, mdpi_barcode: barcoded_object.mdpi_barcode
      expect(response).to have_http_status(401)
    end
  end

  shared_examples "barcode 0" do
    it "assigns @physical_object to nil" do
      expect(assigns(:physical_object)).to be_nil
    end
    it "returns failure XML" do
      expect(response.body).to match /<success>false/
    end
    it "returns failure message XML" do
      expect(response.body).to match /<message>MDPI Barcode.*cannot be 0/
    end
    it "returns a 400 status" do
      expect(response).to have_http_status(400)
    end
  end

  shared_examples "barcode not found" do
    it "assigns @physical_object to nil" do
      expect(assigns(:physical_object)).to be_nil
    end
    it "returns failure XML" do
      expect(response.body).to match /<success>false/
    end
    it "returns failure message XML" do
      expect(response.body).to match /<message>MDPI Barcode.*does not exist/
    end
    it "returns a 200 status" do
      expect(response).to have_http_status(200)
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
    context "with a 0 barcode" do
      before(:each) { get :metadata, mdpi_barcode: physical_object.mdpi_barcode }
      include_examples "barcode 0"
    end
    context "with an unmatched barcode" do
      before(:each) { get :metadata, mdpi_barcode: unmatched_barcode }
      include_examples "barcode not found"
    end
  end

  describe "#full_metadata" do
    context "with a valid barcode" do
      before(:each) { get :full_metadata, mdpi_barcode: barcoded_object.mdpi_barcode }
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
    context "with a 0 barcode" do
      before(:each) { get :full_metadata, mdpi_barcode: physical_object.mdpi_barcode }
      include_examples "barcode 0"
    end
    context "with an unmatched barcode" do
      before(:each) { get :full_metadata, mdpi_barcode: unmatched_barcode }
      include_examples "barcode not found"
    end
  end

  describe "#notify" do
    before(:each) { post :notify, request_xml, content_type: 'application/xml' }
    let(:request_xml) { "<pod><data><message>#{message_text}</message></data></pod>" }
    context "with message text" do
      let(:message_text) { "Hello world" }
      it "creates a notification message" do
        expect(assigns(:notification)).to be_persisted
        expect(assigns(:notification).content).to eq message_text
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
        expect(assigns(:notification)).not_to be_persisted
        expect(Message.first).to be_nil
      end
      it "returns failure xml" do
        expect(response.body).to match /<success>false/
      end
      it "returns 400 status" do
        expect(response).to have_http_status(400)
      end
    end
    # context of message creation failing
  end

  describe "#push_status" do
    before(:each) do
      post :push_status, request_xml, mdpi_barcode: barcoded_object.mdpi_barcode, content_type: 'application/xml'
    end
    context "invalid xml" do
      let(:request_xml) { "<pod><data></data></pod>" }
      skip "FIXME: digital status objects need validations before an invalid request can be made..." do
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
      it "creates a digital status" do
        expect(barcoded_object.digital_statuses.size).to eq 1
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
    context "with a 0 barcode" do
      before(:each) do
        get :pull_state, mdpi_barcode: physical_object.mdpi_barcode
      end
      include_examples "barcode 0"
    end
    context "physical object not found" do
      before(:each) do
        get :pull_state, mdpi_barcode: 1234
      end
      include_examples "barcode not found"
    end
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
      it "returns 200 status" do
        expect(response).to have_http_status(200)
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

  let!(:po_requested) { FactoryGirl.create :physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, staging_requested: true, staged: false }
  let!(:po_nothing) { FactoryGirl.create :physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, staging_requested: false, staged: false }
  let!(:po_staged) { FactoryGirl.create :physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, staging_requested: true, staged: true }
  describe "#trasfers_index" do    
    before(:each) do 
      get :transfers_index
    end

    it "finds only stageable objects" do
      expect(assigns(:pos)).to include(po_requested)
      expect(assigns(:pos)).to_not include(po_nothing)
      expect(assigns(:pos)).to_not include(po_staged)
    end

  end

  describe "#transer_result" do
    before(:each) do
      po_requested.reload
      expect(po_requested.staging_requested).to eq true
      expect(po_requested.staged).to eq false
      post :transfer_result, mdpi_barcode: po_requested.mdpi_barcode
    end

    it "a staged object is updated" do
      po_requested.reload
      expect(po_requested.staged).to eq true
    end
  end

  # FIXME: PENDING rewrite
  describe "#push_memnon_qc" do
    let(:memnon_xml) {
      "<IU xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">
      <Carrier type=\"OpenReel\">
        <Identifier>12079</Identifier>
        <Barcode>#{po_requested.mdpi_barcode}</Barcode>
        <Configuration>
          <Track>Half track</Track>
          <SoundField>Stereo</SoundField>
          <Speed>7.5 ips</Speed>
        </Configuration>
        <Brand>Scotch 208</Brand>
        <Thickness>1.5</Thickness>
        <DirectionsRecorded>1</DirectionsRecorded>
        <PhysicalCondition>
          <Damage>None</Damage>
          <PreservationProblem />
        </PhysicalCondition>
        <Repaired>No</Repaired>
        <Preview>
          <Comments>Some Random Comments</Comments>
        </Preview>
        <Cleaning>
          <Date>2015-02-02 22:05:22</Date>
        </Cleaning>
        <Baking>
          <Date>2015-02-03 22:05:22</Date>
        </Baking>
        <Parts>
          <DigitizingEntity>Memnon Archiving Services Inc</DigitizingEntity>
          <Part Side=\"1\">
            <Ingest>
              <Date>2015-06-02</Date>
              <Comments />
              <Created_by>kgweinbe</Created_by>
              <Player_serial_number>12553</Player_serial_number>
              <Player_manufacturer>Studer</Player_manufacturer>
              <Player_model>A807MK2</Player_model>
              <AD_serial_number />
              <AD_manufacturer>Noa Audio Solutions</AD_manufacturer>
              <AD_model>N6191</AD_model>
              <Extraction_workstation>NoaRec-01</Extraction_workstation>
              <Speed_used>7.5 ips</Speed_used>
            </Ingest>
            <ManualCheck>Yes</ManualCheck>
            <Files>
              <File>
                <FileName>MDPI_40000000089666_01_pres.wav</FileName>
                <CheckSum>5A84DE3449226CF23FF3807D3B567E21</CheckSum>
              </File>
              <File>
                <FileName>MDPI_40000000089666_01_prod.wav</FileName>
                <CheckSum>71D5785DD374F082D7203DB459579949</CheckSum>
              </File>
              <File>
                <FileName>MDPI_40000000089666_01_access.mp4</FileName>
                <CheckSum>27978E7AEF4EA41FD8E8F7A6F61E507E</CheckSum>
              </File>
            </Files>
          </Part>
        </Parts>
      </Carrier>
    </IU>"
    }
    before(:each) do
      po_requested.memnon_qc_completed = false
      #po_requested.ensure_tm
      po_requested.save
      post :push_memnon_qc, memnon_xml, mdpi_barcode: po_requested.mdpi_barcode, content_type: 'application/xml'
    end

    it "sets memnon xml" do
      po_requested.reload
      expect(po_requested.memnon_qc_completed).to eq true
      expect(po_requested.digital_provenance.repaired).to eq false
      expect(po_requested.digital_provenance.comments).to eq "Some Random Comments"
      expect(po_requested.digital_provenance.cleaning_date.to_s).to eq "2015-02-02 17:05:22 -0500"
      expect(po_requested.digital_provenance.baking.to_s).to eq "2015-02-03 17:05:22 -0500"
      expect(po_requested.digital_provenance.digital_file_provenances.size).to eq 1
      expect(po_requested.digital_provenance.digital_file_provenances.first.filename).to eq "MDPI_40000000089666_01_pres.wav"
      expect(po_requested.digital_provenance.digital_file_provenances.first.created_by).to eq "kgweinbe"
      expect(po_requested.digital_provenance.digital_file_provenances.first.player_serial_number).to eq "12553"

      expect(po_requested.digital_provenance.digital_file_provenances.first.player_manufacturer).to eq "Studer"
      expect(po_requested.digital_provenance.digital_file_provenances.first.player_model).to eq "A807MK2"
      expect(po_requested.digital_provenance.digital_file_provenances.first.ad_serial_number).to eq ""
      expect(po_requested.digital_provenance.digital_file_provenances.first.ad_manufacturer).to eq "Noa Audio Solutions"
      expect(po_requested.digital_provenance.digital_file_provenances.first.ad_model).to eq "N6191"
      expect(po_requested.digital_provenance.digital_file_provenances.first.extraction_workstation).to eq "NoaRec-01"
      expect(po_requested.digital_provenance.digital_file_provenances.first.speed_used).to eq "7.5 ips"
    end

    it "fails on invalid barcode" do
      post :push_memnon_qc,memnon_xml, mdpi_barcode: 1, content_type: 'application/xml'
      expect(assigns(:po)).to be_nil
    end
  end

end
