describe MachineFormat do
  let(:machine_format) { FactoryGirl.create :machine_format }
  let(:valid_machine_format) { FactoryGirl.build :machine_format }
  let(:invalid_machine_format) { FactoryGirl.build :machine_format, :invalid }

  describe "FactoryGirl object generation" do
    it "returns a valid object" do
      expect(valid_machine_format).to be_valid
    end
    it "returns an invalid object" do
      expect(invalid_machine_format).not_to be_valid
    end
  end
  describe "has required attributes:" do
    describe "format" do
      it "must be present" do
        valid_machine_format.format = nil
        expect(valid_machine_format).not_to be_valid
      end
      let(:duplicate_machine_format) { FactoryGirl.build :machine_format, machine: machine_format.machine, format: machine_format.format }
      it "must be unique within parent scope" do
        expect(machine_format).to be_valid
        expect(duplicate_machine_format).not_to be_valid
      end
    end
  end
  describe "has relationships:" do
    describe "machine" do
      it "is required" do
        valid_machine_format.machine = nil
        expect(valid_machine_format).not_to be_valid
      end
    end
  end
end
