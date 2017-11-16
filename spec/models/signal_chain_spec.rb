describe SignalChain do
  let(:format) { "CD-R" }
  let(:signal_chain) { FactoryBot.create :signal_chain }
  let(:dfp) { FactoryBot.create :digital_file_provenance, signal_chain: signal_chain }
  let(:machine) { FactoryBot.create :machine }
  let(:processing_step) { FactoryBot.create :processing_step, :with_formats, formats: [format], signal_chain: signal_chain, machine: machine }
  let(:valid_signal_chain) { FactoryBot.build :signal_chain }
  let(:invalid_signal_chain) { FactoryBot.build :signal_chain, :invalid }

  describe "FactoryBot object generation" do
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
    specify "signal chain formats destroyed if signal chain is destroyed" do
      signal_chain.signal_chain_formats.create!(format: format)
      expect { signal_chain.destroy }.to change(SignalChainFormat, :count).by(-1)
    end
    specify "digital_file_provenances" do
      expect(valid_signal_chain).to respond_to :digital_file_provenances
    end
    specify "digital_file_provenances block deletion" do
      signal_chain.signal_chain_formats.create!(format: format)
      dfp
      expect { signal_chain.destroy }.not_to change(SignalChain, :count)
      expect(signal_chain.errors).not_to be_empty
      expect(signal_chain.errors.full_messages.join).to match /dependent digital file provenances/
    end
  end

  describe "has attributes:" do
    [:name, :studio].each do |attr|
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
