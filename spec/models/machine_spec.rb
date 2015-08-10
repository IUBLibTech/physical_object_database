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

end
