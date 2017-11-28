describe MdpiBarcodeValidator do
  let(:validator) { MdpiBarcodeValidator.new({attributes: { mdpi_barcode: 0}}) }
  let(:physical_object) { FactoryBot.build :physical_object, :barcoded, :cdr }
  describe "validate_each" do
    context "with an invalid barcode" do
      it "adds an error message" do
        expect(physical_object.errors).to be_empty
        validator.validate_each(physical_object, :mdpi_barcode, "42")
        expect(physical_object.errors).not_to be_empty
        expect(physical_object.errors.full_messages.first).to match /is not valid/
      end
    end
    context "with a valid barcode" do
      context "with a collision" do
        let(:colliding_po) { FactoryBot.create :physical_object, :barcoded, :cdr }
        it "adds an error" do
          expect(physical_object.errors).to be_empty
          validator.validate_each(physical_object, :mdpi_barcode, colliding_po.mdpi_barcode)
          expect(physical_object.errors).not_to be_empty
          expect(physical_object.errors.full_messages.first).to match /already.*assigned/
        end
      end
      context "without a collision" do
        it "does not add an error" do
          expect(physical_object.errors).to be_empty
          validator.validate_each(physical_object, :mdpi_barcode, physical_object.mdpi_barcode)
          expect(physical_object.errors).to be_empty
        end
      end
    end
  end
  describe "error_message_link" do
    [Bin, Box, PhysicalObject].each do |klass|
      describe "collision with #{klass.to_s}" do
        it "returns an error message" do
          expect(validator.send(:error_message_link, klass.new)).to match /has already been assigned to a #{klass.to_s.titleize}/
        end
      end
    end
  end
end
