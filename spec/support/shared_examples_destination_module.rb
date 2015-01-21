#
# requires test object as argument
#
shared_examples "destination module examples" do |test_object|

  describe "destination module effects:" do
    it "requires a destination" do
     expect(test_object.destination).not_to be_blank
     test_object.destination = ""
     expect(test_object).to be_invalid
    end
  
    it "requires a valid destination value" do
      test_object.destination = "INVALID DESTINATION VALUE"
      expect(test_object).to be_invalid
    end
  
    it "gets a default destination of Memnon" do
      test_object.destination = nil
      test_object.default_destination
      expect(test_object.destination).to eq "Memnon"
    end
  
    it "provides valid values hash constant" do
      expect(test_object.class.DESTINATION_VALUES.keys.sort).to eq ["IU", "Memnon"].sort
    end

  end
end

