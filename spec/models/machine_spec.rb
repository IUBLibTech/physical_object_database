describe Machine do
  let(:machine) { FactoryGirl.create :machine }
  let(:valid_machine) { FactoryGirl.build :machine }
  let(:invalid_machine) { FactoryGirl.build :machine, :invalid }

  describe "FactoryGirl object generation" do
    it "returns a valid object" do
      expect(valid_machine).to be_valid
    end
    it "returns an invalid object" do
      expect(invalid_machine).not_to be_valid
    end
  end

  describe "has relationships:" do
    specify "processing steps" do
      expect(valid_machine.processing_steps.size).to be > -1
    end
    specify "signal chains" do
      expect(valid_machine.signal_chains.size).to be > -1
    end
    specify "machine formats" do
      expect(valid_machine.machine_formats).to respond_to :size
    end
  end

  describe "has attributes:" do
    [:category, :serial, :manufacturer, :model].each do |attr|
      specify "#{attr}" do
        expect(valid_machine).to respond_to(attr)
        expect(valid_machine.attributes.keys).to include(attr.to_s)
      end
    end
    describe "has required attributes:" do
      [:category, :serial].each do |attr|
        specify "#{attr}" do
          valid_machine.send((attr.to_s + "=").to_sym, nil)
          expect(valid_machine).not_to be_valid
        end
      end
    end
  end

  describe "#formats" do
    it "returns an array" do
      expect(valid_machine.formats).to be_a Array
    end
    let(:format) { "CD-R" }
    it "includes format values" do
      valid_machine.machine_formats.new(format: format)
      expect(valid_machine.formats).to include format
    end
  end

end
