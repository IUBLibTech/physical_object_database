#
# requires let statements for:
# target_object
#
shared_examples "default_values examples" do |values_hash|

  describe "#default_values" do
    values_hash.each do |att, val|
      it "sets #{att} to #{val.nil? ? 'nil' : val.to_s }" do
        target_object.send("#{att}=", nil)
        target_object.default_values
        expect(target_object.send(att)).to eq val
      end
    end
  end

end

