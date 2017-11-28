describe QcXmlModule do
  let(:including_class) { Class.new { include QcXmlModule } }
  let(:test_object) { including_class.new }
  let(:po) { FactoryBot.create :physical_object, :cdr }
  let(:digitizing_entity) { 'Memnon Archiving Services Inc' }
  let(:manual_check) { 'No' }
  let(:xml) { '<?xml version="1.0"?>
<IU xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Carrier type="OpenReel">
    <Identifier>12229</Identifier>
    <Barcode>40000000754061</Barcode>
    <Configuration>
      <Track>Half track</Track>
      <SoundField>Stereo</SoundField>
      <Speed>7.5 ips</Speed>
    </Configuration>
    <Brand>Scotch 208/209</Brand>
    <Thickness />
    <DirectionsRecorded>1</DirectionsRecorded>
    <PhysicalCondition>
      <Damage>None</Damage>
      <PreservationProblem />
    </PhysicalCondition>
    <Repaired>No</Repaired>
    <Preview>
      <Comments />
    </Preview>
    <Cleaning>
      <Date xsi:nil="true" />
    </Cleaning>
    <Baking>
      <Date xsi:nil="true" />
    </Baking>
    <Parts>
      <DigitizingEntity>Memnon Archiving Services Inc</DigitizingEntity>
      <Part Side="1">
        <Ingest>
          <Date>2015-06-03</Date>
          <Comments />
          <Created_by>kgweinbe</Created_by>
          <Player_serial_number>16811</Player_serial_number>
          <Player_manufacturer>Studer</Player_manufacturer>
          <Player_model>A807MK2</Player_model>
          <AD_serial_number>0038</AD_serial_number>
          <AD_manufacturer>Noa Audio Solutions</AD_manufacturer>
          <AD_model>N6191</AD_model>
          <Extraction_workstation>NoaRec-01 </Extraction_workstation>
          <Speed_used>7.5 ips</Speed_used>
        </Ingest>
        <ManualCheck>' + manual_check + '</ManualCheck>
        <Files>
          <File>
            <FileName>MDPI_40000000754061_01_pres.wav</FileName>
            <CheckSum>AE7C99D572E98BD426EE7B193B2C5CE1</CheckSum>
          </File>
          <File>
            <FileName>MDPI_40000000754061_01_prod.wav</FileName>
            <CheckSum>C67323D010FC213EA574DDD5B93BD54B</CheckSum>
          </File>
          <File>
            <FileName>MDPI_40000000754061_01_access.mp4</FileName>
            <CheckSum>12EBAD1D66995690A45E1DCA7E5CD5C0</CheckSum>
          </File>
        </Files>
      </Part>
    </Parts>
  </Carrier>
</IU>
'}
  let(:doc) { Nokogiri::XML(xml).remove_namespaces! }

  describe "#parse_qc_xml(po, xml, doc)" do
    it "assigns xml to po.digital_provenance and saves" do
      expect(po.ensure_digiprov.xml).to be_nil
      test_object.parse_qc_xml(po, xml, doc)
      expect(po.ensure_digiprov.xml).not_to be_nil
      expect(po.ensure_digiprov.xml).to eq xml
    end
    it "sets the digital_provenance.digitizing entity value" do
      expect(po.ensure_digiprov.digitizing_entity).to be_nil
      test_object.parse_qc_xml(po, xml, doc)
      expect(po.ensure_digiprov.digitizing_entity).not_to be_nil
      expect(po.ensure_digiprov.digitizing_entity).to eq digitizing_entity
    end
    describe "sets po.memnon_qc_completed via ManualCheck fields" do
      shared_examples "ManualCheck examples" do |check_result|
        it "sets to #{check_result}" do
          expect(po.memnon_qc_completed).to be_nil
          test_object.parse_qc_xml(po, xml, doc)
          expect(po.memnon_qc_completed).to eq check_result
        end
      end
      context "(with No value)" do
        let(:manual_check) { 'No' }
        include_examples "ManualCheck examples", false
      end
      context "(with Yes value)" do
        let(:manual_check) { 'Yes' }
        include_examples "ManualCheck examples", true
      end
    end
  end
end
