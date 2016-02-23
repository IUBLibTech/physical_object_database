describe DigitalStatus do
	let!(:po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
	let!(:po_vid) { FactoryGirl.create(:physical_object, :betacam, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
	let!(:start) { FactoryGirl.create(:digital_status, :valid, physical_object_id: po.id, physical_object_mdpi_barcode: po.mdpi_barcode) }
	let!(:start_vid) { FactoryGirl.create(:digital_status, :valid, physical_object_id: po_vid.id, physical_object_mdpi_barcode: po_vid.mdpi_barcode) }
  let(:valid_ds) { FactoryGirl.build(:digital_status, :valid) }
  let(:invalid_ds) { FactoryGirl.build(:digital_status, :invalid) }

	describe "auto accept finds the object" do

		context "with only a non-expired start time" do
			it "does nothing - po has not expired" do
				DigitalFileAutoAcceptor.instance.auto_accept
				expect(po.current_digital_status.decided).to be_nil 
			end
		end

		context "with an expired start time and in qc_wait" do
			let!(:qc_wait) {
				FactoryGirl.create(:digital_status,
					physical_object_id: po.id,
					physical_object_mdpi_barcode: po.mdpi_barcode,
					state: 'qc_wait',
					attention: true,
					message: 'waiting on manual QC',
					options: {"a"=>"to_distribute","b"=>"to_archive","c"=>"to_delete"},
					decided: nil
				)
			}

			let!(:qc_wait_vid) {
				FactoryGirl.create(:digital_status,
					physical_object_id: po_vid.id,
					physical_object_mdpi_barcode: po_vid.mdpi_barcode,
					state: 'qc_wait',
					attention: true,
					message: 'waiting on manual QC',
					options: {"a"=>"to_distribute","b"=>"to_archive","c"=>"to_delete"},
					decided: nil
				)
			}

			before(:each) do
				time = start.created_at - 41.day
				vid_time = start.created_at - 31.day
				start.update_attributes(created_at: time)
				start_vid.update_attributes(created_at: vid_time)
				po.update_attributes(digital_start: time)
				po_vid.update_attributes(digital_start: vid_time)
			end

			it "is in qc_wait state" do
				expect(po.current_digital_status.state).to eq 'qc_wait'
				expect(po_vid.current_digital_status.state).to eq 'qc_wait'

				expect(DigitalStatus.expired_audio_physical_objects).to include po
				expect(DigitalStatus.expired_audio_physical_objects).not_to include po_vid
				expect(DigitalStatus.expired_video_physical_objects).not_to include po
				expect(DigitalStatus.expired_video_physical_objects).to include po_vid


				DigitalFileAutoAcceptor.instance.auto_accept

				expect(po.current_digital_status.decided).to eq "qc_passed"
				expect(po_vid.current_digital_status.decided).to eq "qc_passed"
			end

			it "is in investigate" do
				qc_wait.state = "investigate"
				qc_wait_vid.state = "investigate"
				qc_wait.save
				qc_wait_vid.save

				expect(po.current_digital_status.state).to eq 'investigate'
				expect(po_vid.current_digital_status.state).to eq 'investigate'

				expect(DigitalStatus.expired_audio_physical_objects).to include po
				expect(DigitalStatus.expired_audio_physical_objects).not_to include po_vid
				expect(DigitalStatus.expired_video_physical_objects).not_to include po
				expect(DigitalStatus.expired_video_physical_objects).to include po_vid

				DigitalFileAutoAcceptor.instance.auto_accept

				expect(po.current_digital_status.decided).to eq "to_archive"
				expect(po_vid.current_digital_status.decided).to eq "to_archive"
				
			end
		end


	end

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_ds).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_ds).not_to be_valid
    end
  end
  { required: [:physical_object, :physical_object_mdpi_barcode],
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
  # test serialization of options?
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
        FactoryGirl.create_list(:digital_status, count, :valid, state: status.to_s, options: { foo: 1, bar: 2})
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
    describe "current_status(state)" do
      before(:each) { DigitalStatus.where(state: 'transferred').each { |ds| ds.options = { foo: 1, bar: 2 } } }
      describe "returns physical_objects in that state" do
        results.each do |status, count|
          specify "#{status}: #{count}" do
            expect(DigitalStatus.current_status(status.to_s).size).to eq count
          end
        end
      end
    end
    describe "current_actionable_status(state)" do
      before(:each) { DigitalStatus.where(state: 'transferred').each { |ds| ds.options = { foo: 1, bar: 2 } } }
      describe "returns physical_objects in that state" do
        results.each do |status, count|
          specify "#{status}: #{count}" do
            expect(DigitalStatus.current_status(status.to_s).size).to eq count
          end
        end 
      end
    end
  end
  #
  # scopes
  # :action_statuses
  # :decided_action_barcodes
  # :expired_audio_physical_objects
  # :expired_video_physical_objects
  #
  # methods
  # DigitalStatus.test
  # self.unique_statuses_query
  # from_json
  # from_xml
  # select_options
  # from_xml**
  #
  # virtual attributes
  # requires_attention? DEPRECATED
  # decided? DEPRECATED
  # before_save NOT RUNNING??
end
