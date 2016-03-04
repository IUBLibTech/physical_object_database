# requires arguments:
# string_attribute, boolean_attribute
#
# requires let statements:
# target_object
#
shared_examples "includes XMLExportModule" do |string_attribute, boolean_attribute|

  describe "class_constants" do
    [:XML_INCLUDE, :XML_EXCLUDE].each do |module_constant|
      specify "#{module_constant} is an Array" do
        expect(target_object.class.const_get(module_constant)).to be_a Array
      end
    end
  end

  describe "#to_xml" do
    it "returns XML" do
      expect(target_object.to_xml).to match /xml/
    end
    it "converts a nil string attribute (#{string_attribute}) to ''" do
      target_object.send("#{string_attribute}=", nil)
      expect(target_object[string_attribute]).to be_nil
      target_object.to_xml
      expect(target_object[string_attribute]).to eq ""
    end
    it "converts a nil Boolean attribute (#{boolean_attribute}) to false" do
      target_object.send("#{boolean_attribute}=", nil)
      expect(target_object[boolean_attribute]).to be_nil
      target_object.to_xml
      expect(target_object[boolean_attribute]).to eq false
    end

  end

end

