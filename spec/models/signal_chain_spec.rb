describe SignalChain do
  let(:signal_chain) { FactoryGirl.create :signal_chain }
  let(:machine) { FactoryGirl.create :machine }
  let(:processing_step) { FactoryGirl.create :processing_step, signal_chain: signal_chain, machine: machine }
  let(:valid_signal_chain) { FactoryGirl.build :signal_chain }
  let(:invalid_signal_chain) { FactoryGirl.build :signal_chain, :invalid }

  describe "FactoryGirl object generation" do
    it "returns a valid object" do
      expect(valid_signal_chain).to be_valid
    end
    it "returns an invalid object" do
      expect(invalid_signal_chain).not_to be_valid
    end
  end

  describe "has relationships:" do
    specify "processing steps" do
      expect(valid_signal_chain.processing_steps.size).to be > -1
    end
    specify "processing steps destroyed if signal chain is destroyed" do
      processing_step
      expect { signal_chain.destroy }.to change(ProcessingStep, :count).by(-1)
    end
    specify "machines" do
      expect(valid_signal_chain.machines.size).to be > -1
    end
    specify "signal chain formats" do
      expect(valid_signal_chain.signal_chain_formats).to respond_to :size
    end
  end

  describe "has attributes:" do
    [:name].each do |attr|
      specify "#{attr}" do
        expect(valid_signal_chain).to respond_to(attr)
        expect(valid_signal_chain.attributes.keys).to include(attr.to_s)
      end
    end
    describe "has required attributes:" do
      [:name].each do |attr|
        specify "#{attr}" do
          valid_signal_chain.send((attr.to_s + "=").to_sym, nil)
          expect(valid_signal_chain).not_to be_valid
        end
      end
    end
    describe "requires unique values:" do
      specify "name" do
        valid_signal_chain.name = signal_chain.name + "different"
        expect(valid_signal_chain).to be_valid
        valid_signal_chain.name = signal_chain.name
        expect(valid_signal_chain).not_to be_valid
      end
    end
  end

  describe "#formats" do
    it "returns an array" do
      expect(valid_signal_chain.formats).to be_a Array 
    end
    let(:format) { "CD-R" }
    it "includes format values" do
      valid_signal_chain.signal_chain_formats.new(format: format)
      expect(valid_signal_chain.formats).to include format
    end
  end

end
