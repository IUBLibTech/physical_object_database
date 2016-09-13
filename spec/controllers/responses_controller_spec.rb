describe ResponsesController do
  render_views
  # use BasicAuth instead of CAS
  before(:each) do
    basic_auth
    request.env['HTTP_REFERER'] = 'source_page'
  end
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr }
  let(:barcoded_object) { FactoryGirl.create :physical_object, :cdr, :barcoded }
  let(:format_version_object) { FactoryGirl.create :physical_object, :vhs, :barcoded }
  let(:test_object) do
    test_object = FactoryGirl.create :physical_object, :cdr
    test_object.mdpi_barcode = 49000000000000
    test_object.save!(validate: false)
    test_object
  end
  let(:group_key) { FactoryGirl.create :group_key }
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
    shared_examples "with a valid barcode" do
      before(:each) { get :metadata, mdpi_barcode: target_object.mdpi_barcode }
      it "assigns @physical_object" do
        expect(assigns(:physical_object)).to eq target_object
      end
      it "returns success=true XML" do
        expect(response.body).to match /<success.*true<\/success>/
      end
      it "returns data XML" do
        expect(response.body).to match /<data>/
        expect(response.body).to match /<format>#{target_object.format}<\/format>/
        expect(response.body).to match /<files>#{target_object.technical_metadatum.specific.master_copies}<\/files>/
      end
      it "returns a 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    context "with a format that does not have format_version" do
      let(:target_object) { barcoded_object }
      include_examples "with a valid barcode"
      it "does NOT return format_version in data XML" do
        expect(response.body).not_to match /<format_version/
      end
    end
    context "with a format that has format_version" do
      let(:target_object) { format_version_object }
      include_examples "with a valid barcode"
      it "returns format_version in data XML" do
        expect(response.body).to match /<format_version>#{format_version_object.ensure_tm.format_version}<\/format_version>/
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
        expect(response.body).to match /<files>#{physical_object.technical_metadatum.specific.master_copies}<\/files>/
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

  describe "#digiprov_metadata" do
    context "with a valid barcode" do
      let(:get_digiprov) { get :digiprov_metadata, mdpi_barcode: barcoded_object.mdpi_barcode }
      context "with complete digiprov" do
        before(:each) do
          dp = barcoded_object.digital_provenance
          dp.duration = 100
          dp.save!
          get_digiprov
        end
        it "assigns @physical_object" do
          expect(assigns(:physical_object)).to eq barcoded_object
          expect(assigns(:physical_object).digital_provenance).to be_complete
        end
        it "returns success=true XML" do
          expect(response.body).to match /<success.*true<\/success>/
        end
        it "returns data XML" do
          expect(response.body).to match /<data>/
          expect(response.body).to match /<format>#{physical_object.format}<\/format>/
        end
        it "returns a 200 status" do
          expect(response).to have_http_status(200)
        end
      end
      context "with incomplete digiprov" do
        before(:each) do
          dfp = barcoded_object.digital_provenance.digital_file_provenances.create!(filename: "MDPI_#{barcoded_object.mdpi_barcode}_01_pres.wav")
          get_digiprov
        end
        it "assigns @physical_object" do
          expect(assigns(:physical_object)).to eq barcoded_object
        end
        it "returns success=false XML" do
          expect(response.body).to match /<success.*false<\/success>/
        end
        it "returns failure message XML" do
          expect(response.body).to match /<message>/
        end
        it "returns a 400 status" do
          expect(response).to have_http_status(400)
        end
      end
    end
    context "with a 0 barcode" do
      before(:each) { get :digiprov_metadata, mdpi_barcode: physical_object.mdpi_barcode }
      include_examples "barcode 0"
    end
    context "with an unmatched barcode" do
      before(:each) { get :digiprov_metadata, mdpi_barcode: unmatched_barcode }
      include_examples "barcode not found"
    end
  end

  describe "#grouping" do
    context "with a valid barcode" do
      before(:each) { get :grouping, mdpi_barcode: barcoded_object.mdpi_barcode }
      it "assigns @physical_object" do
        expect(assigns(:physical_object)).to eq barcoded_object
      end
      it "returns success=true XML" do
        expect(response.body).to match /<success.*true<\/success>/
      end
      it "returns data XML" do
        expect(response.body).to match /<data>/
        expect(response.body).to match /<group_identifier>#{barcoded_object.group_key.group_identifier}<\/group_identifier>/
        expect(response.body).to match /<group_total>#{barcoded_object.group_key.group_total}<\/group_total>/
        expect(response.body).to match /<physical_objects_count>#{barcoded_object.group_key.physical_objects_count}<\/physical_objects_count>/
        expect(response.body).to match /<physical_objects>/
        expect(response.body).to match /<physical_object>/
        expect(response.body).to match /<group_position>#{barcoded_object.group_position}<\/group_position>/
        expect(response.body).to match /<mdpi_barcode>#{barcoded_object.mdpi_barcode}<\/mdpi_barcode>/
      end
      it "returns a 200 status" do
        expect(response).to have_http_status(200)
      end
    end
    context "with a 0 barcode" do
      before(:each) { get :grouping, mdpi_barcode: physical_object.mdpi_barcode }
      include_examples "barcode 0"
    end
    context "with an unmatched barcode" do
      before(:each) { get :grouping, mdpi_barcode: unmatched_barcode }
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
          <state>#{state}</state>
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
      shared_examples "valid xml examples" do
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
      context "for digital_status_start value" do
        let(:state) { DigitalStatus::DIGITAL_STATUS_START }
        include_examples "valid xml examples"
        it "updates physical_object.digital_start" do
          expect(barcoded_object.digital_start).to be_nil
          barcoded_object.reload
          expect(barcoded_object.digital_start).not_to be_nil
        end
      end
      context "for other values" do
        let(:state) { 'accept' }
        include_examples "valid xml examples"
        it "does not update physical_object.digital_start" do
          expect(barcoded_object.digital_start).to be_nil
          barcoded_object.reload
          expect(barcoded_object.digital_start).to be_nil
        end

      end
    end
  end

  describe "#pull_memnon_qc" do
    let(:pull_memnon_qc) { get :pull_memnon_qc, mdpi_barcode: barcoded_object.mdpi_barcode }
    context "with no provenance" do
      before(:each) do
        barcoded_object.digital_provenance.destroy!
        barcoded_object.reload
        expect(barcoded_object.digital_provenance).to be_nil
        pull_memnon_qc
      end
      it "renders No digiprov model" do
        expect(response.body).to match /No digiprov model/
      end
    end
    context "with a provenance" do
      before(:each) { expect(barcoded_object.digital_provenance).not_to be_nil }
      context "with no xml" do
        before(:each) do
          barcoded_object.digital_provenance.update_attributes!(xml: nil)
          pull_memnon_qc
        end
        it "renders No xml digiprov" do
          expect(response.body).to match /No xml digiprov/
        end
      end
      context "with xml" do
        let(:xml) { "<xml>TEST XML</xml>" }
        before(:each) do
          barcoded_object.digital_provenance.update_attributes!(xml: xml )
          pull_memnon_qc
        end
        it "renders No xml digiprov" do
          expect(response.body).to eq xml
        end
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

  describe "#pull_states" do
    before(:each) { get :pull_states }
    it "renders response template" do
      expect(response).to render_template 'responses/pull_states.xml.builder'
    end
  end

  let!(:po_requested) { FactoryGirl.create :physical_object, :cdr, :barcoded, staging_requested: true, staged: false }
  let!(:po_nothing) { FactoryGirl.create :physical_object, :cdr, :barcoded, staging_requested: false, staged: false }
  # Below case should not happen -- but if it did, it would be included in results
  let!(:po_staged) { FactoryGirl.create :physical_object, :cdr, :barcoded, staging_requested: true, staged: true }
  describe "#transfers_index" do    
    before(:each) do 
      get :transfers_index
    end

    it "finds only stageable objects" do
      expect(assigns(:pos)).to include(po_requested)
      expect(assigns(:pos)).to_not include(po_nothing)
      expect(assigns(:pos)).to include(po_staged)
    end

  end

  describe "#transfer_result" do
    context "with a found barcode" do
      before(:each) do
        po_requested.reload
        expect(po_requested.staging_requested).to eq true
        expect(po_requested.staged).to eq false
        post :transfer_result, mdpi_barcode: po_requested.mdpi_barcode
      end
      it "sets success to true" do
        expect(assigns(:success)).to eq true
      end
      it "a staged object is updated" do
        po_requested.reload
        expect(po_requested.staged).to eq true
      end
      it "renders response" do
        expect(response).to render_template 'responses/notify.xml.builder'
      end
    end
    context "without finding the barcode" do
      before(:each) do
        post :transfer_result, mdpi_barcode: 42
      end
      it "does not set success to true" do
        expect(assigns(:success)).not_to eq true
      end
      it "sets failure message" do
        expect(assigns(:message)).to match /Could not find/i
      end
      it "renders response" do
        expect(response).to render_template 'responses/notify.xml.builder'
      end

    end
  end

  describe "#push_memnon_qc" do
    let(:xml) { '<?xml version="1.0" encoding="utf-8"?>
<IU xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Carrier xsi:type="VinylsCarrier" type="Vinyls">
    <Identifier>EHRET LP-S ZAe.286</Identifier>
    <Barcode>' + po_requested.mdpi_barcode.to_s + '</Barcode>
    <PhysicalCondition>
      <Damage />
      <PreservationProblem />
    </PhysicalCondition>
    <Parts>
      <DigitizingEntity>' + digitizing_entity + '</DigitizingEntity>
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
            <FileName>MDPI_40000000527434_01_access.mkv</FileName>
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
      post :push_memnon_qc, xml, mdpi_barcode: mdpi_barcode, content_type: 'application/xml'
    end
    shared_examples "po record not found examples" do
      it "sets @success to false" do
        expect(assigns(:success)).to eq false
      end
      it "sets @message to 'Could not find'" do
        expect(assigns(:message)).to match /could not find/i
      end
      it "renders response template" do
        expect(response).to render_template 'responses/notify.xml.builder'
      end
    end
    context "for memnon" do
      let(:digitizing_entity) { DigitalProvenance::MEMNON_DIGITIZING_ENTITY }
      context "for found po record" do
        let(:mdpi_barcode) { po_requested.mdpi_barcode }
        it "sets @success to true" do 
          expect(assigns(:success)).to eq true 
        end
        it "sets @message to saved memnon digiprov xml" do
          expect(assigns(:message)).to match /saved memnon digiprov/i
        end
        it "sets physical_object.digitizing_entity" do
          po_requested.digital_provenance.reload
          expect(po_requested.digital_provenance.digitizing_entity).to eq digitizing_entity
        end
        it "sets digiprov xml" do
          po_requested.digital_provenance.reload
          expect(po_requested.digital_provenance.xml).not_to be_nil
        end
        it "renders response template" do
          expect(response).to render_template 'responses/notify.xml.builder'
        end
      end
      context "when po record not found" do
        let(:mdpi_barcode) { 42 }
        include_examples "po record not found examples"
      end
      context "with an error" do
        let(:error_po) do
          error_po = FactoryGirl.create :physical_object, :cdr, :barcoded
          error_po.unit = nil
          error_po.save!(validate: false)
          error_po
        end
        let(:mdpi_barcode) { error_po.mdpi_barcode }
        it "sets message to Something went wrong" do
          expect(assigns(:message)).to match /something went wrong/i
        end
      end
    end
    context "for IU" do
      let(:digitizing_entity) { DigitalProvenance::IU_DIGITIZING_ENTITY }
      context "for found po record" do
        let(:mdpi_barcode) { po_requested.mdpi_barcode }
        it "sets @success to true" do
          expect(assigns(:success)).to eq true
        end
        it "sets @message to set digitizing entity" do
          expect(assigns(:message)).to match /set digitizing entity/i
        end
        it "sets physical_object.digitizing_entity" do
          po_requested.digital_provenance.reload
          expect(po_requested.digital_provenance.digitizing_entity).to eq digitizing_entity
        end
        it "does not save digiprov xml" do
          po_requested.digital_provenance.reload
          expect(po_requested.digital_provenance.xml).to be_nil
        end
        it "renders response template" do
          expect(response).to render_template 'responses/notify.xml.builder'
        end
      end
      context "when po record not found" do
        let(:mdpi_barcode) { 42 }
        include_examples "po record not found examples"
      end
    end
    context "for unknown digitizing entity" do
      let(:digitizing_entity) { "unknown entity" }
      let(:mdpi_barcode) { po_requested.mdpi_barcode }
      it "fails" do
        expect(assigns(:success)).to eq false
      end
      it "sets message: unknown entity" do
        expect(assigns(:message)).to match /unknown.*entity/i
      end
    end
  end

  describe "#unit_full_name" do
    let(:unit) { Unit.first }
    it "finds the correct full name" do
      get :unit_full_name, abbreviation: unit.abbreviation
      expect(response.body).to match "<success>true"
      expect(response.body).to match "<message>#{unit.name}"
    end

    it "fails on bad abbreviation" do
      get :unit_full_name, abbreviation: "foobar"
      expect(response.body).to match "<success>false"
    end
  end

  describe "#all_units" do
    it "gets a lits of all units" do
      get :all_units
      expect(response.body).to match "<success>true"
      expect(response.body).to match "<units>"
      doc = Nokogiri::XML(response.body).remove_namespaces!
      units = doc.css("unit").size
      count = Unit.all.size
      expect(units).to eq count
    end
  end

  describe "#flags" do
    let(:no_flag) { FactoryGirl.create :physical_object, :cdr, :barcoded}
    let(:flag) { FactoryGirl.create :physical_object, :cdr, :barcoded}

    context "DigiProv without a flag" do
      before(:each) { 
        get :flags, mdpi_barcode: no_flag.mdpi_barcode 
      }
      
      it "a successful but, no-flag call" do
        expect(assigns(:physical_object)).to eq no_flag
        expect(response).to have_http_status(200)
        expect(response.body).to match /<data>/
        expect(response.body).to match /<success.*true<\/success>/
        expect(response.body).to match /<flags\/>/
        expect(response.body).not_to match /<flags>.*<\/flags>/
      end
    end

    context "with a flag set" do
      before(:each) {
        flag.digital_provenance.batch_processing_flag = "Some Flag!"
        flag.digital_provenance.save
        get :flags, mdpi_barcode: flag.mdpi_barcode
      }
      it "has the correct flag" do
        expect(assigns(:physical_object)).to eq flag
        expect(response).to have_http_status(200)
        expect(response.body).to match /<data>/
        expect(response.body).to match /<success.*true<\/success>/
        expect(response.body).to match /<flags>Some Flag!<\/flags>/
      end
    end

  end

  describe "digitizing entity" do
    let(:get_digitizing_entity) { get :digitizing_entity, mdpi_barcode: mdpi_barcode }
    context "when physical object not found" do
      let(:mdpi_barcode) { 42 }
      before(:each) { get_digitizing_entity }
      it "sets @message to Unknown physical object" do
        expect(assigns(:message)).to match /Unknown physical object/i
      end
      it "renders response" do
        expect(response).to render_template 'responses/notify.xml.builder'
      end
    end
    context "when physical object found" do
      let(:po) { FactoryGirl.create(:physical_object, :cdr, :barcoded) }
      let(:mdpi_barcode) { po.mdpi_barcode }
      context "when digitizing_entity does not exist" do
        before(:each) do
          po.digital_provenance.update_attributes!(digitizing_entity: nil)
          expect(po.digital_provenance.digitizing_entity).to be_nil
          get_digitizing_entity
        end
        it "sets @message to Digitizing entity not set" do
          expect(assigns(:message)).to match /Digitizing entity not set/i
        end
        it "renders response" do 
          expect(response).to render_template 'responses/notify.xml.builder' 
        end
      end
      context "when digitizing_entity exists" do
        before(:each) do
          po.digital_provenance.update_attributes!(digitizing_entity: DigitalProvenance::MEMNON_DIGITIZING_ENTITY)
          expect(po.digital_provenance.digitizing_entity).not_to be_nil
          get_digitizing_entity
        end
        it "sets @message to digitizing entity" do
          expect(assigns(:message)).to eq po.digital_provenance.digitizing_entity
        end
        it "renders response" do 
          expect(response).to render_template 'responses/notify.xml.builder' 
        end
      end
    end
  end
  
  describe "#clear" do
    let(:clear_by_barcode) { get :clear, mdpi_barcode: target_barcode }
    before(:each) do
      [barcoded_object, test_object].each do |target_object|
        ds = target_object.digital_statuses.new
        ds.save!
      end
      clear_by_barcode
    end
    context "with unmatched barcode" do
      let(:target_barcode) { 42 }
      it "sets @message to could not find" do
        expect(assigns(:message)).to match /could not find/i
      end
      it "renders response template" do
        expect(response).to render_template 'responses/notify.xml.builder'
      end
    end
    context "with non-test barcode" do
      let(:target_barcode) { barcoded_object.mdpi_barcode }
      it "sets @message to could not find" do
        expect(assigns(:message)).to match /could not find/i
      end
      it "renders response template" do
        expect(response).to render_template 'responses/notify.xml.builder'
      end
    end
    context "with test barcode" do
      let(:target_barcode) { test_object.mdpi_barcode }
      it "sets @success to true" do
        expect(assigns(:success)).to eq true
      end
      it "sets @message to success message" do
        expect(assigns(:message)).to match /digital statuses.*deleted/i
      end
      it "clears po digital_statuses" do
        test_object.reload
        expect(test_object.digital_statuses).to be_empty
      end
      it "renders response template" do
        expect(response).to render_template 'responses/notify.xml.builder'
      end
    end
  end

  describe "#clear_all" do
    let(:clear_all) { get :clear_all }
    before(:each) do
      [barcoded_object, test_object].each do |target_object|
        ds = target_object.digital_statuses.new
        ds.save!
      end
      clear_all
    end
    it "clears all digital_statuses for test records" do
      test_object.reload
      expect(test_object.digital_statuses).to be_empty
    end
    it "does not clear out digital_statuses for non-test records" do
      barcoded_object.reload
      expect(barcoded_object.digital_statuses).not_to be_empty
    end
    it "sets success=true" do
      expect(assigns(:success)).to eq true
    end
    it "sets deleted message" do
      expect(assigns(:message)).to match /deleted digital statuses/
    end
  end

  describe "#avalon_url" do
    let(:avalon_url) { "avalon.url" }
    let(:valid_xml) { "<pod><data><avalonUrl>#{avalon_url}</avalonUrl></data></pod>" }
    let(:invalid_xml) { "<foo><bar>foobar</bar></foo>" }
    context "GET action" do
      let(:get_avalon_url) { get :avalon_url, group_key_id: id }
      context "without finding group key" do
        let(:id) { 0 }
        before(:each) { get_avalon_url }
        it "sets @success to false" do
          expect(assigns(:success)).to eq false
        end
        it "sets @message to Could not find GroupKey" do
          expect(assigns(:message)).to match /Could not find GroupKey/i
        end
        it "renders template" do
          expect(response).to render_template 'responses/notify.xml.builder'
        end
      end
      context "finding a group key" do
        let(:id) { group_key.id }
        context "with a URL set" do
          before(:each) do
            group_key.update_attributes!(avalon_url: avalon_url)
            get_avalon_url
          end
          it "assigns @success = true" do 
            expect(assigns(:success)).to eq true
          end
          it "sets @message to group_key.avalon_url" do
            expect(assigns(:message)).to eq avalon_url
          end
          it "renders notify response" do
            expect(response).to render_template 'responses/notify.xml.builder'
          end

        end
        context "without a url set" do
          before(:each) do
            group_key.update_attributes!(avalon_url: nil)
            get_avalon_url
          end
          it "assigns @success = true" do
            expect(assigns(:success)).to eq true
          end
          it "sets @message to No url set" do
            expect(assigns(:message)).to match /no url set/i
          end
          it "renders notify response" do
            expect(response).to render_template 'responses/notify.xml.builder'
          end
        end
      end
    end
    context "POST action" do
      before(:each) { post :avalon_url, request_xml, group_key_id: id, content_type: 'application/xml' }
      context "without finding group key" do
        let(:id) { 0 }
        let(:request_xml) { valid_xml }
        it "sets @success to false" do
          expect(assigns(:success)).to eq false
        end
        it "sets @message to Could not find GroupKey" do
          expect(assigns(:message)).to match /Could not find GroupKey/i
        end
        it "renders template" do
          expect(response).to render_template 'responses/notify.xml.builder'
        end
      end
      context "finding group_key" do
        let(:id) { group_key.id }
        context "with invalid xml" do
          let(:request_xml) { invalid_xml }
          it "sets @success to false" do
            expect(assigns(:success)).to eq false
          end
          it "sets @message to Something went wrong" do
            expect(assigns(:message)).to match /Something went wrong/i
          end
          it "renders template" do
            expect(response).to render_template 'responses/notify.xml.builder'
          end
        end
        context "with valid xml" do
          let(:request_xml) { valid_xml }
          it "sets @success to true" do
            expect(assigns(:success)).to eq true
          end
          it "sets @message to Success" do
            expect(assigns(:message)).to match /Success/i
          end
          it "updates group_key.avalon_url" do
            expect(group_key.avalon_url).not_to eq avalon_url
            group_key.reload
            expect(group_key.avalon_url).to eq avalon_url
          end
          it "renders template" do
            expect(response).to render_template 'responses/notify.xml.builder'
          end
        end
      end
    end
  end
end
