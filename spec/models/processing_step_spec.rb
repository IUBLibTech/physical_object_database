describe ProcessingStep do
  let(:processing_step) { FactoryGirl.create :processing_step }
  let(:valid_processing_step) { FactoryGirl.build :processing_step }
  let(:invalid_processing_step) { FactoryGirl.build :processing_step, :invalid }

  describe "FactoryGirl object generation" do
    it "returns a valid object" do
      expect(valid_processing_step).to be_valid
    end
    it "returns an invalid object" do
      expect(invalid_processing_step).not_to be_valid
    end
  end

  describe "has relationships" do
    specify "signal_chain" do
      expect(processing_step.signal_chain).to be_a SignalChain
    end
    specify "machine" do
      expect(processing_step.machine).to be_a Machine
    end
  end

  describe "has attributes:" do
    [:position].each do |attr|
      specify "#{attr}" do
        expect(valid_processing_step).to respond_to(attr)
        expect(valid_processing_step.attributes.keys).to include(attr.to_s)
      end
    end
    describe "has required attributes:" do
      [:position, :signal_chain, :machine].each do |attr|
        specify "#{attr}" do
          valid_processing_step.send((attr.to_s + "=").to_sym, nil)
          expect(valid_processing_step).not_to be_valid
        end
      end
    end
    specify "position must be positive" do
      valid_processing_step.position = 0
      expect(valid_processing_step).not_to be_valid
    end
    pending "position must be unique for a given signal chain"
  end

end
