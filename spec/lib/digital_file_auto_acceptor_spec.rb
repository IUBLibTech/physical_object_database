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
    pending "write logger tests"
  end

  describe "#auto_accept" do
    pending "write auto_accept tests"
  end

  describe "#start" do
    pending "write thread start tests, if feasible"
  end

  describe "#stop" do
    pending "write thread stop tests, if feasible"
  end

end
