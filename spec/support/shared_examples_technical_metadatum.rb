#
# requires arguments for:
# tm_object
#
shared_examples "includes technical metadatum behaviors" do |tm_object|

  describe "has boolean fieldsets:" do
    tm_object.class::MULTIVALUED_FIELDSETS.each_pair do |description, constant_key|
      describe "#{description}" do
        tm_object.class.const_get(constant_key).each do |field|
          it "includes boolean field: #{field}" do
            expect(tm_object.send(field.to_sym)).to eq false
	  end
        end
      end
    end
  end

  describe "has relationships:" do
    it "can belong to a picklist specification" do
      expect(tm_object.picklist_specification).to be_nil
    end
    it "can belong to a physical object" do
      expect(tm_object.physical_object).to be_nil
    end
  end

end

