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
      '<?xml version="1.0" encoding="utf-8"?>
<IU xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Carrier xsi:type="VinylsCarrier" type="Vinyls">
    <Identifier>EHRET LP-S ZAe.286</Identifier>
    <Barcode>' + po_requested.mdpi_barcode.to_s + '</Barcode>
    <PhysicalCondition>
      <Damage />
      <PreservationProblem />
    </PhysicalCondition>
    <Parts>
      <DigitizingEntity>Memnon Archiving Services Inc</DigitizingEntity>
      <Part Side="1">
        <Ingest xsi:type="VinylsIngest">
          <Date>2015-08-12</Date>
          <Comments>Signal - Very large number of clicks;</Comments>
          <Created_by>chmalex</Created_by>
          <Player_serial_number>GE2JY001246</Player_serial_number>
          <Player_manufacturer>Technics</Player_manufacturer>
          <Player_model>SL-1210 MKII</Player_model>
          <Extraction_workstation>BL-UITS-DCDT027</Extraction_workstation>
          <AD_serial_number>01504-0906-025</AD_serial_number>
          <AD_manufacturer>Mytek</AD_manufacturer>
          <AD_model>8X192 ADDA</AD_model>
          <Preamp_serial_number>MD123058</Preamp_serial_number>
          <Preamp_manufacturer>Vad Lyd</Preamp_manufacturer>
          <Preamp_model>MD12 MK3</Preamp_model>
          <Speed_used>33.3 rpm</Speed_used>
        </Ingest>
        <ManualCheck>Yes</ManualCheck>
        <QcComment>Significant clicks due to scratch; Missing material (00:50-02:52)</QcComment>
        <Files>
          <File>
            <FileName>MDPI_40000000527434_01_pres.wav</FileName>
            <CheckSum>31C7502AE276EDEB30E0A492233BF54F</CheckSum>
          </File>
          <File>
            <FileName>MDPI_40000000527434_01_prod.wav</FileName>
            <CheckSum>F31C44FCFB29541CA874CAD345C6C32E</CheckSum>
          </File>
          <File>
            <FileName>MDPI_40000000527434_01_access.mp4</FileName>
            <CheckSum>B01FEC101B4B4283F99A7B9558834845</CheckSum>
          </File>
        </Files>
      </Part>
      <Part Side="2">
        <Ingest xsi:type="VinylsIngest">
          <Date>2015-08-11</Date>
          <Comments>Disc - Physical defect disabling (continuous) playback;Disc - Stylus jump;</Comments>
          <Created_by>chmalex</Created_by>
          <Player_serial_number>GE2JY001246</Player_serial_number>
          <Player_manufacturer>Technics</Player_manufacturer>
          <Player_model>SL-1210 MKII</Player_model>
          <Extraction_workstation>BL-UITS-DCDT027</Extraction_workstation>
          <AD_serial_number>01504-0906-025</AD_serial_number>
          <AD_manufacturer>Mytek</AD_manufacturer>
          <AD_model>8X192 ADDA</AD_model>
          <Preamp_serial_number>MD123058</Preamp_serial_number>
          <Preamp_manufacturer>Vad Lyd</Preamp_manufacturer>
          <Preamp_model>MD12 MK3</Preamp_model>
          <Speed_used>33.3 rpm</Speed_used>
        </Ingest>
        <ManualCheck>Yes</ManualCheck>
        <QcComment />
        <Files />
      </Part>
    </Parts>
    <Configuration xsi:type="ConfigurationVinyls">
      <Speed>33.3 rpm</Speed>
      <RecordingType>Lateral</RecordingType>
    </Configuration>
    <Cleaning>
      <Date>2015-08-11</Date>
      <Comment />
    </Cleaning>
    <Preview>
      <Comments />
    </Preview>
  </Carrier>
</IU>'
    }
    before(:each) do
      po_requested.memnon_qc_completed = false
      #po_requested.ensure_tm
      po_requested.save
      post :push_memnon_qc, memnon_xml, mdpi_barcode: po_requested.mdpi_barcode, content_type: 'application/xml'
    end

    it "sets memnon xml" do
      skip "FIXME: still waiting on final spec for Memnon digiprov XML and what to do in case of failure..." do
        po_requested.reload
        expect(po_requested.memnon_qc_completed).to eq true
        expect(po_requested.digital_provenance.repaired).to eq false
        expect(po_requested.digital_provenance.comments).to eq "Some Random Comments"
        expect(po_requested.digital_provenance.cleaning_date.to_s).to eq "2015-02-02 17:05:22 -0500"
        expect(po_requested.digital_provenance.baking.to_s).to eq "2015-02-03 17:05:22 -0500"
        # these tests are currently not necessary because digital file provenance is no longer parsed
        # expect(po_requested.digital_provenance.digital_file_provenances.size).to eq 1
        # expect(po_requested.digital_provenance.digital_file_provenances.first.filename).to eq "MDPI_40000000089666_01_pres.wav"
        # expect(po_requested.digital_provenance.digital_file_provenances.first.created_by).to eq "kgweinbe"
        # expect(po_requested.digital_provenance.digital_file_provenances.first.speed_used).to eq "7.5 ips"
      end
    end

    it "fails on invalid barcode" do
      post :push_memnon_qc,memnon_xml, mdpi_barcode: 1, content_type: 'application/xml'
      expect(assigns(:po)).to be_nil
    end
  end

end
