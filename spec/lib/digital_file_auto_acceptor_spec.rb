describe DigitalFileAutoAcceptor do

  describe "#total_mins(time)" do
    {"at 10:30pm" => [22.5, 22 * 60 + 30],
     "at 11:30pm" => [23.5, 23 * 60 + 30],
     "at 00:30am" => [ 0.5, 30]}.each do |time_desc, values|
      context "#{time_desc}  (#{Time.gm(2000,1,1) + values.first * 60 * 60})" do
        it "returns #{values.last}" do
	  expect(DigitalFileAutoAcceptor.instance.total_mins(Time.gm(2000,1,1) + values.first * 60 * 60)).to eq values.last
        end
      end
    end
  end

  describe "#in_time_window?" do
    {"at 10:30pm" => [22.5, false],
     "at 11:30pm" => [23.5, true],
     "at 00:30am" => [ 0.5, false]}.each do |time_desc, values|
      context "#{time_desc} (#{Time.gm(2000,1,1) + values.first * 60 * 60})" do
        it "returns #{values.last}" do
          expect(DigitalFileAutoAcceptor.instance.in_time_window?(Time.gm(2000,1,1) + values.first * 60 * 60)).to eq values.last
        end
      end
    end
  end

  describe "#wait_seconds" do
    {"at 10:30pm" => [22.5,  0.5 * 60 * 60],
     "at 11:30pm" => [23.5, 23.5 * 60 * 60],
     "at 00:30am" => [ 0.5, 22.5 * 60 * 60]}.each do |time_desc, values|
      context "#{time_desc} (#{Time.gm(2000,1,1) + values.first * 60 * 60})" do
        it "returns #{values.last}" do
          expect(DigitalFileAutoAcceptor.instance.wait_seconds(Time.gm(2000,1,1) + values.first * 60 * 60)).to eq values.last
        end
      end
    end
  end

  describe "#thread_active?" do
    after(:each) { DigitalFileAutoAcceptor.instance.stop }
    context "when thread is active" do
      it "returns true" do
        DigitalFileAutoAcceptor.instance.start
	sleep 1
        expect(DigitalFileAutoAcceptor.instance.thread_active?).to eq true
      end
    end
    context "when thread is inactive" do
      it "returns false" do
        expect(DigitalFileAutoAcceptor.instance.thread_active?).to eq false
      end
    end
  end

  describe "#aa_logger" do
    it "returns a Logger instance" do
      expect(DigitalFileAutoAcceptor.instance.aa_logger).to be_a Logger
    end
  end

  describe "#auto_accept" do
    let(:state_updates) { DigitalFileAutoAcceptor::STATE_UPDATES }
    let(:audio_objects) { FactoryGirl.create_list :physical_object, state_updates.size, :barcoded, :cdr }
    let(:video_objects) { FactoryGirl.create_list :physical_object, state_updates.size, :barcoded, :betacam }
    # FIXME: add film format
    # let(:film_objects) { FactoryGirl.create_list :physical_object, state_updates.size, :barcoded, :film }
    shared_examples "auto_accept examples" do #requires let(:object_set)
      before(:each) do
        object_set.each_with_index do |po_object, index|
          po_object.init_start_digital_status
          po_object.digital_start = digital_start
          po_object.save!
          ds = po_object.current_digital_status
          ds.options["key"] = "value"
          ds.decided = nil
          ds.state = state_updates.keys[index]
          ds.save!
        end
      end
      context "for expired objects" do
        let(:digital_start) { Time.new(Time.now.year - 1, Time.now.month, Time.now.day) }
        it "updates current digital status decided value appropriately" do
          DigitalFileAutoAcceptor.instance.auto_accept
          object_set.each_with_index do |po_object, index|
            po_object.reload
            expect(po_object.current_digital_status.decided).to eq state_updates.values[index]
          end
        end
      end
      context "for unexpired objects" do
        let(:digital_start) { Time.now }
        it "does not update current digital status decided value" do
          DigitalFileAutoAcceptor.instance.auto_accept
          object_set.each_with_index do |po_object, index|
            po_object.reload
            expect(po_object.current_digital_status.decided).to be_nil
          end
        end
      end
    end
    context "on audio objects" do
      let(:object_set) { audio_objects }
      include_examples "auto_accept examples"
    end
    context "on video objects" do
      let(:object_set) { video_objects }
      include_examples "auto_accept examples"
    end
    context "on film objects" do
      xit "FIXME: need example film format"
      # let(:object_set) { film_objects }
      # include_examples "auto_accept examples"
    end
  end

  describe "#start" do
    after(:each) { DigitalFileAutoAcceptor.instance.stop }
    it "starts a thread" do
      expect(DigitalFileAutoAcceptor.instance.thread_active?).to eq false
      DigitalFileAutoAcceptor.instance.start
      expect(DigitalFileAutoAcceptor.instance.thread_active?).to eq true
    end
  end

  describe "#stop" do
    after(:each) { DigitalFileAutoAcceptor.instance.stop }
    it "stops a thread" do
      DigitalFileAutoAcceptor.instance.start 
      expect(DigitalFileAutoAcceptor.instance.thread_active?).to eq true
      DigitalFileAutoAcceptor.instance.stop
      expect(DigitalFileAutoAcceptor.instance.thread_active?).to eq false
    end
  end

end
