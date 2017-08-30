#
# requires arguments for:
# tm_object
#
shared_examples "includes TechnicalMetadatumModule" do |tm_object|

  describe "provides class constants:" do
    specify "TM_FORMAT as Array of Strings" do
      expect(tm_object.class.const_get(:TM_FORMAT).first.class).to eq String
    end
    specify "TM_SUBTYPE as Boolean" do
      expect(tm_object.class.const_get(:TM_SUBTYPE)).to be_in([true, false])
    end
    specify "TM_GENRE as :audio/:video/:film" do
      expect(tm_object.class.const_get(:TM_GENRE)).to be_in([:audio, :video, :film])
    end
    specify "TM_PARTIAL as String" do
      expect(tm_object.class.const_get(:TM_PARTIAL).class).to eq String
    end
    specify "BOX_FORMAT, BIN_FORMAT as Booleans" do
      expect(tm_object.class.const_get(:BOX_FORMAT)).to be_in([true, false])
      expect(tm_object.class.const_get(:BIN_FORMAT)).to be_in([true, false])
      expect(tm_object.class.const_get(:BOX_FORMAT) || tm_object.class.const_get(:BIN_FORMAT)).to eq true
    end
  end

  describe "has boolean fieldsets:" do
    tm_object.class::MULTIVALUED_FIELDSETS.each_pair do |description, constant_key|
      describe "#{description}" do
        tm_object.class.const_get(constant_key).each do |field|
          it "includes boolean field: #{field}" do
            expect([true, false]).to include tm_object[field]
	  end
        end
      end
    end
  end

  describe "has relationships:" do
    it "can belong to a picklist specification" do
      expect(tm_object).to respond_to :picklist_specification_id
    end
    it "can belong to a physical object" do
      expect(tm_object).to respond_to :physical_object_id
    end
  end

  describe "#master_copies" do
    it "provides a positive numeric value" do
      expect(tm_object.master_copies).to be > 0
    end
  end

  # "damage" is a required real or virtual property of all TM types
  describe "#damage" do
    it "returns a string" do
      expect(tm_object.damage.class).to eq String
    end
  end

  describe "#export_headers" do
    it "returns a non-empty array of header values" do
      expect(tm_object.export_headers.size).to be > 0
    end
  end

  describe "#export_values" do
    it "returns a non-empty array of values" do
      expect(tm_object.export_values.size).to be > 0
    end
    it "returns a value for each export header" do
      expect(tm_object.export_values.size).to eq tm_object.export_headers.size
    end
  end

  describe "#provenance_requirements" do
    it "returns a hash" do
      expect(tm_object.provenance_requirements).to be_a Hash
    end
    it "returns the class constant" do
      expect(tm_object.provenance_requirements).to eq tm_object.class::PROVENANCE_REQUIREMENTS
    end
  end

  describe "provides class methods" do 
    describe "::valid_headers" do
      it "returns an array of valid headers" do
        expect(tm_object.class.valid_headers).not_to be_empty
      end
    end
    describe "::human_attribute_name" do
      it "returns a string" do
        expect(tm_object.class.human_attribute_name("foo_bar")).to eq "Foo bar"
      end
    end
    describe "::hashify" do
      it "turns an array into a hash of reflexive string values" do
        expect(tm_object.class.hashify([1, :foo])).to eq Hash[[["1","1"],["foo","foo"]]]
      end
    end
    describe "::parse_tm" do
      let!(:multivalued_fieldsets) { tm_object.class.const_get(:MULTIVALUED_FIELDSETS) }
      let!(:simple_fields) { tm_object.class.const_get(:SIMPLE_FIELDS) }
      let!(:row) { {} }
      context "with valid values" do
        before(:each) do
          simple_fields.each do |field|
            tm_object[field] = "old value"
            row[tm_object.class.human_attribute_name(field)] = "new value"
          end
          multivalued_fieldsets.each do |name, fieldset_constant|
            fields = tm_object.class.const_get(fieldset_constant)
            row[name] = fields.map { |x| tm_object.class.human_attribute_name(x) }.join(",")
            fields.each do |field|
              tm_object[field] = false
            end
          end
        end
        describe "updates simple values:" do
          tm_object.class.const_get(:SIMPLE_FIELDS).each do |field|
            unless field.in? ["directions_recorded"] #exemption for calculated fields
              specify field do
                expect(tm_object[field]).to eq "old value"
                tm_object.class.parse_tm(tm_object, row)
                expect(tm_object[field]).to eq "new value"
              end 
            end
          end
        end
        describe "updates boolean fieldsets:" do
          tm_object.class.const_get(:MULTIVALUED_FIELDSETS).each do |name, fieldset_constant|
            describe name do
              tm_object.class.const_get(fieldset_constant).each do |field|
                specify field do
                  expect(tm_object[field]).to eq false
                  tm_object.class.parse_tm(tm_object, row)
                  expect(tm_object[field]).to eq true
                  tm_object[field] = false
                end
              end
            end
          end
        end
      end
      if tm_object.class.const_get(:MULTIVALUED_FIELDSETS).any?
        context "with invalid values" do
          before(:each) do
            row[tm_object.class.const_get(:MULTIVALUED_FIELDSETS).first.first] = "Invalid Value"
          end
          it "reports an error" do
            tm_object.class.parse_tm(tm_object, row)
            expect(tm_object.errors[:base]).not_to be_empty
            expect(tm_object.errors[:base].first).to match /not a valid value/
          end
        end
      end
    end
    describe "::PROVENANCE_REQUIREMENTS" do
      specify "exist" do
        expect{tm_object.class::PROVENANCE_REQUIREMENTS}.not_to raise_error
      end
    end
  end

  describe "#hashify" do
    it "turns an array into a hash of reflexive string values" do
      expect(tm_object.hashify([1, :foo])).to eq Hash[[["1","1"],["foo","foo"]]]
    end
  end

  describe "#preservation_problems" do
    it "returns humanize_boolean_fieldset(:PRESERVATION_PROBLEM_FIELDS) or blank, for film" do
     if tm_object.class == FilmTm
       expect(tm_object.preservation_problems).to be_blank
     else
       expect(tm_object.preservation_problems).to eq tm_object.humanize_boolean_fieldset(:PRESERVATION_PROBLEM_FIELDS)
     end
   end
  end

  describe "#to_xml" do
    it "returns an XML string" do
      expect(tm_object.to_xml).to be_a String
    end
    context "specifying a format" do
      let(:format) { "test format" }
      it "uses the specifed format" do
        expect(tm_object.to_xml(format: format)).to match "<format>#{format}</format>"
      end
    end
    context "without specifying a format" do
      context "with an object" do
        before(:each) do
          tm_object.physical_object = FactoryGirl.build(:physical_object, :cdr) if tm_object.respond_to?(:physical_object)
          expect(tm_object.physical_object).not_to be_nil
        end
        it "uses the object format" do
          expect(tm_object.to_xml()).to match "<format>#{tm_object.physical_object.format}</format>"
        end
      end
      context "without an object" do
        before(:each) do
          tm_object.physical_object = nil if tm_object.respond_to?(:physical_object)
          expect(tm_object.physical_object).to be_nil
        end
        it "returns an Unknown format value" do
          expect(tm_object.to_xml()).to match "<format>Unknown</format>"
        end
      end
    end
  end
  describe "#manifest_values" do
    it "returns an Array" do
      expect(tm_object.manifest_values).to be_a Array
      expect(tm_object.manifest_values.size).to eq tm_object.class.const_get(:MANIFEST_EXPORT).size
    end
  end
  describe "::format_auto_accept_days" do
    shared_examples "format_auto_accept_days examples" do |format, format_days|
      specify "TechnicalMetadatumModule::format_auto_accept_days(format) returns GENRE_AUTO_ACCEPT_DAYS for the format genre" do
        expect(TechnicalMetadatumModule.format_auto_accept_days(format)).to eq format_days
      end
    end
    context "for an audio format" do
      include_examples "format_auto_accept_days examples", "CD-R", 40
    end
    context "for a video format" do
      include_examples "format_auto_accept_days examples", "U-matic", 30
    end
  end
end
