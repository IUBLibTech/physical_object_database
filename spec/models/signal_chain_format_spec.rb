describe SignalChainFormat do
  let(:signal_chain_format) { FactoryBot.create :signal_chain_format }
  let(:valid_signal_chain_format) { FactoryBot.build :signal_chain_format }
  let(:invalid_signal_chain_format) { FactoryBot.build :signal_chain_format, :invalid }

  describe "FactoryBot object generation" do
    it "returns a valid object" do
      expect(valid_signal_chain_format).to be_valid
    end
    it "returns an invalid object" do
      expect(invalid_signal_chain_format).not_to be_valid
    end
  end
  describe "has required attributes:" do
    describe "format" do
      it "must be present" do
        valid_signal_chain_format.format = nil
        expect(valid_signal_chain_format).not_to be_valid
      end
      let(:duplicate_signal_chain_format) { FactoryBot.build :signal_chain_format, signal_chain: signal_chain_format.signal_chain, format: signal_chain_format.format }
      it "must be unique within parent scope" do
        expect(signal_chain_format).to be_valid
        expect(duplicate_signal_chain_format).not_to be_valid
      end
    end
  end
  describe "has relationships:" do
    describe "signal_chain" do
      it "is required" do
        valid_signal_chain_format.signal_chain = nil
        expect(valid_signal_chain_format).not_to be_valid
      end
    end
  end
end
