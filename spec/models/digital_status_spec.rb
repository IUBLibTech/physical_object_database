describe DigitalStatus do
  let(:po) { FactoryGirl.create(:physical_object, :cdr, :barcoded) }
  let(:valid_ds) { FactoryGirl.build(:digital_status, :valid) }
  let(:invalid_ds) { FactoryGirl.build(:digital_status, :invalid) }

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_ds).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_ds).not_to be_valid
    end
  end
  { required: [:physical_object],
    # :physical_object_mdpi_barcode is also required, but automatically set via the physical_object
    optional: [:state, :message, :accepted, :attention, :decided, :options, :decided_manually, :created_at, :updated_at] }.each do |type, attributes|
    describe "has #{type.to_s} attributes:" do
      attributes.each do |att|
        specify "#{att}" do
          valid_ds.send(((att.to_s)+'=').to_sym, nil)
          expect(valid_ds.valid?).to eq (type == :optional)
        end
      end
    end
  end
  describe "has class constants:" do
    { :DIGITAL_STATUS_START => 'transferred'}.each do |constant, value|
      specify "#{constant.to_s} has value #{value}" do
        expect(DigitalStatus.const_get(constant)).to eq value
      end
    end
  end
  describe "has class variables" do
    { :@@Video_File_Auto_Accept => 30 * 24,
      :@@Audio_File_Auto_Accept => 40 * 24, }.each do |constant, value|
      specify "#{constant.to_s} has value #{value}" do
        expect(DigitalStatus.class_variable_get(constant)).to eq value
      end
    end
  end
  describe "has relationships" do
    describe "physical object" do
      it "belongs to" do
        expect(valid_ds).to respond_to :physical_object
      end
      it "is required" do
        valid_ds.physical_object = nil
        expect(valid_ds).not_to be_valid
      end
    end
  end
  describe "scopes" do
    results = { failed: 3, queued: 4 }
    before(:each) do
      results.each do |status, count|
        ds_list = FactoryGirl.create_list(:digital_status, count, :valid, state: status.to_s, options: { foo: 1, bar: 2})
        ds_list.each do |ds|
          po = FactoryGirl.create :physical_object, :cdr, :barcoded
          ds.physical_object = po
#ds.decided = status.to_s + ' decision'
          ds.save!
        end
      end
    end
    describe "unique_statuses" do
      describe "returns array of arrays containing status, count pairs:" do
        results.each do |status, count|
          specify "#{status}: #{count}" do
            expect(DigitalStatus.unique_statuses).to include [status.to_s, count]
          end
        end
      end
    end
    describe "current_actionable_status(state)" do
      describe "returns physical_objects in that state" do
        results.each do |status, count|
          specify "#{status}: #{count}" do
            expect(DigitalStatus.current_actionable_status(status.to_s).size).to eq count
          end
        end 
      end
    end
    describe "action_statuses" do
      describe "returns state, count pairs for actionable states" do
        results.each do |status, count|
          specify "#{status}: #{count}" do
            expect(DigitalStatus.action_statuses).to include [status.to_s, count]
          end
        end
      end
    end
    describe "decided_action_barcodes" do
      describe "returns mdpi_barcode, decided pairs for actionable states" do
        context "with no decided states" do
          it "returns no results" do
            expect(DigitalStatus.decided_action_barcodes.to_a).to be_empty
          end
        end
        context "with decided states" do
          before(:each) do
            DigitalStatus.all.each do |ds|
              ds.decided = "#{ds.physical_object.mdpi_barcode} decided"
              ds.save!
            end
          end
          it "returns the decided states" do
            DigitalStatus.all.each do |ds|
              expect(DigitalStatus.decided_action_barcodes).to include [ds.physical_object.mdpi_barcode, "#{ds.physical_object.mdpi_barcode} decided"]
            end
          end
        end
      end
    end
    describe "expired object scopes:" do
      let!(:unexpired_time) { Time.now }
      let!(:expired_time) { unexpired_time - 365.days }
      let!(:unexpired_audio) { FactoryGirl.create :physical_object, :cdr, digital_start: unexpired_time }
      let!(:expired_audio) { FactoryGirl.create :physical_object, :cdr, digital_start: expired_time }
      let!(:unexpired_video) { FactoryGirl.create :physical_object, :umatic, digital_start: unexpired_time }
      let!(:expired_video) { FactoryGirl.create :physical_object, :umatic, digital_start: expired_time }
      let!(:unexpired_film) { FactoryGirl.create :physical_object, :film, digital_start: unexpired_time }
      let!(:expired_film) { FactoryGirl.create :physical_object, :film, digital_start: expired_time }
      before(:each) do
        [unexpired_audio, expired_audio, unexpired_video, expired_video, unexpired_film, expired_film].each do |po|
          ds = FactoryGirl.build :digital_status, physical_object: po, options: { foo: 'bar' }
          ds.save!
        end
      end
      describe "expired_audio_physical_objects" do
        it "returns expired audio objects" do
          expect(DigitalStatus.expired_audio_physical_objects).to eq [expired_audio]
        end
      end
      describe "expired_video_physical_objects" do
        it "returns expired video objects" do
          expect(DigitalStatus.expired_video_physical_objects).to eq [expired_video]
        end
      end
      describe "expired_film_physical_objects" do
        it "returns expired film objects" do
          expect(DigitalStatus.expired_film_physical_objects).to eq [expired_film]
        end
      end
    end
  end

  describe "object methods:" do
    describe "from_json(json)" do
      before(:each) { valid_ds.attributes.keys.each { |att| valid_ds[att] = nil }; valid_ds.physical_object = nil }
      JSON_TEXT = ""
      let(:json) { "{\"barcode\":#{mdpi_barcode},\"state\":\"test json state\",\"message\":\"test json message\",\"message\":\"test json message\",\"attention\":\"true\",\"options\":{ \"option\": \"result\" }}" }
      shared_examples "from_json examples" do
        it "assigns mdpi_barcode" do
          expect(valid_ds.physical_object_mdpi_barcode).to be_nil
          valid_ds.from_json(json)
          expect(valid_ds.physical_object_mdpi_barcode).to eq mdpi_barcode
        end
        it "assigns po based on barcode match" do
          expect(valid_ds.physical_object).to be_nil
          valid_ds.from_json(json)
          expect(valid_ds.physical_object).to eq target_object
        end
        describe "assigns attributes from json:" do
          [:state, :message, :accepted, :attention].each do |att|
            specify att do
              expect(valid_ds[att].to_s).to be_blank
              valid_ds.from_json(json)
              expect(valid_ds[att].to_s).not_to be_blank
            end
          end
          [:options].each do |att|
            specify att do
              expect(valid_ds[att]).to be_empty
              valid_ds.from_json(json)
              expect(valid_ds[att]).not_to be_empty
            end
          end
        end
        specify "sets decided to nil" do
          valid_ds.decided = true
          expect(valid_ds.decided).not_to be_nil
          valid_ds.from_json(json)
          expect(valid_ds.decided).to be_nil
        end
      end
      context "with matching mdpi_barcode" do
        let(:mdpi_barcode) { po.mdpi_barcode }
        let(:target_object) { po }
        include_examples "from_json examples"
      end
      context "with non-matching mdpi_barcode" do
        let(:mdpi_barcode) { invalid_mdpi_barcode }
        let(:target_object) { nil }
        include_examples "from_json examples"
      end
    end
    describe "from_xml(mdpi_barcode, xml)" do
      before(:each) { valid_ds.attributes.keys.each { |att| valid_ds[att] = nil }; valid_ds.physical_object = nil }
      XML_TEXT = "<pod>
				<data>
					<state>test state</state>
					<message>test message</message>
					<attention>true</attention>
					<options>
						<option>
							<state>test option state</state>
							<description>test option description</description>
						</option>
					</options>
				</data>
		</pod>"
      let(:xml) { Nokogiri::XML(XML_TEXT) }
      shared_examples "from_xml examples" do
        it "assigns mdpi_barcode" do
          expect(valid_ds.physical_object_mdpi_barcode).to be_nil
          valid_ds.from_xml(mdpi_barcode, xml)
          expect(valid_ds.physical_object_mdpi_barcode).to eq mdpi_barcode
        end
        it "assigns po based on barcode match" do
          expect(valid_ds.physical_object).to be_nil
          valid_ds.from_xml(mdpi_barcode, xml)
          expect(valid_ds.physical_object).to eq target_object
        end
        describe "assigns attributes from xml:" do
          [:state, :message, :accepted, :attention].each do |att|
            specify att do
              expect(valid_ds[att].to_s).to be_blank
              valid_ds.from_xml(mdpi_barcode, xml)
              expect(valid_ds[att].to_s).not_to be_blank
            end
          end
          [:options].each do |att|
            specify att do
              expect(valid_ds[att]).to be_empty
              valid_ds.from_xml(mdpi_barcode, xml)
              expect(valid_ds[att]).not_to be_empty
            end
          end
        end
        specify "sets decided to nil" do
          valid_ds.decided = true
          expect(valid_ds.decided).not_to be_nil
          valid_ds.from_xml(mdpi_barcode, xml)
          expect(valid_ds.decided).to be_nil
        end
      end
      context "with matching mdpi_barcode" do
        let(:mdpi_barcode) { po.mdpi_barcode }
        let(:target_object) { po }
        include_examples "from_xml examples"
      end
      context "with non-matching mdpi_barcode" do
        let(:mdpi_barcode) { invalid_mdpi_barcode }
        let(:target_object) { nil }
        include_examples "from_xml examples"
      end
    end
    describe "select_options" do
      context "with any options set" do
        before(:each) { valid_ds.options = { foo: :bar } }
        it "converts serialized options hash to array of paired value arrays" do
          valid_ds.options 
          expect(valid_ds.select_options).to eq valid_ds.options.map{|key, value| [value, key.to_s]}
        end
      end
      context "with no options set" do
        before(:each) { valid_ds.options = nil }
        it "returns an empty array" do
          expect(valid_ds.select_options).to eq []
        end
      end
    end
  end

  describe "#set_mdpi_barcode_from_object" do
    context "with no object" do
      before(:each) { valid_ds.physical_object = nil; valid_ds.physical_object_mdpi_barcode = nil }
      it "returns nil" do
        expect(valid_ds.set_mdpi_barcode_from_object).to be_nil
      end
      it "does not assign a barcode" do
        valid_ds.set_mdpi_barcode_from_object
        expect(valid_ds.physical_object_mdpi_barcode).to be_nil
      end
    end
    context "with an object, but no barcode" do
      before(:each) { valid_ds.physical_object_mdpi_barcode = nil; expect(valid_ds.physical_object).not_to be_nil }
      it "returns the barcode" do
        expect(valid_ds.set_mdpi_barcode_from_object).to eq valid_ds.physical_object.mdpi_barcode
      end
      it "assigns the barcode" do
        valid_ds.set_mdpi_barcode_from_object
        expect(valid_ds.physical_object_mdpi_barcode).to eq valid_ds.physical_object.mdpi_barcode
      end

    end
  end

  describe "statuses" do
    context "that are actionable" do
      ['dist_failed', 'failed', 'qc_failed', 'qc_wait', 'rejected'].each do |s|
        it "DigitalStatus.actionalbe_status? returns true on #{s}" do
            expect(DigitalStatus.actionable_status?(s)).to eq true
        end
      end
    end
    context "that are not actionable" do
      [ "archived", 'basic_qc', 'ch2dlib', 'deleted', 'long_processing', 'migrate_wait', 'processing', 'purged', 'purging', 'staging', 'to_distribute'].each do |s|
        context "#{s}" do
          it "DigitalStatus.actionable_status? returns false on #{s}" do
            expect(DigitalStatus.actionable_status?(s)).to eq false
          end
        end
      end
    end
  end

end
