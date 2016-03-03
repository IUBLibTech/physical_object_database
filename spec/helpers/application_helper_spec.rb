describe ApplicationHelper do
  let(:valid_barcode) { 40152053079381 }
  let(:invalid_barcode) { 40152053079380 }
  let(:zero_barcode) { 0 }
  let(:physical_object) { FactoryGirl.create :physical_object, :cdr, mdpi_barcode: valid_barcode }
  let(:bin) { FactoryGirl.create :bin, mdpi_barcode: valid_barcode }
  let(:box) { FactoryGirl.create :box, mdpi_barcode: valid_barcode }

  describe "::valid_barcode?" do
    it "accepts a 0 barcode" do
      expect(ApplicationHelper.valid_barcode?(0)).to eq true
    end
    it "rejects a nil barcode" do
      expect(ApplicationHelper.valid_barcode?(nil)).to eq false
    end
    it "rejects a short barcode" do
      expect(ApplicationHelper.valid_barcode?(valid_barcode / 10)).to eq false
    end
    it "rejects a long barcode" do
      expect(ApplicationHelper.valid_barcode?(valid_barcode * 10)).to eq false
    end
    it "rejects an invalid barcode" do
      expect(ApplicationHelper.valid_barcode?(invalid_barcode)).to eq false
    end
    it "accepts a valid barcode" do
      expect(ApplicationHelper.valid_barcode?(valid_barcode)).to eq true
    end
  end

  describe "::real_barcode?(barcode)" do
    context "with a invalid barcode" do
      it "returns false" do
        expect(ApplicationHelper.real_barcode?(invalid_barcode)).to eq false
      end
    end
    context "with a valid barcode" do
      context "of zero" do
        it "returns false" do
          expect(ApplicationHelper.real_barcode?(zero_barcode)).to eq false
        end
      end
      context "(non-zero)" do
        it "returns true" do
          expect(ApplicationHelper.real_barcode?(valid_barcode)).to eq true
        end
      end
    end
  end

  describe "#error_messages_for(object)" do
    it "renders application/error_message" do
      allow(helper).to receive(:render)
      helper.error_messages_for(physical_object)
      expect(helper).to have_received(:render).with(partial: 'application/error_messages', locals: {object: physical_object})
    end
  end

  describe "::barcode_assigned?" do
    it "returns bin, if assigned to bin" do
      bin
      expect(ApplicationHelper.barcode_assigned?(bin.mdpi_barcode)).to eq bin
    end
    it "returns box, if assigned to box" do
      box
      expect(ApplicationHelper.barcode_assigned?(box.mdpi_barcode)).to eq box
    end
    it "returns physical object, if assigned to physical object" do
      physical_object
      expect(ApplicationHelper.barcode_assigned?(physical_object.mdpi_barcode)).to eq physical_object
    end
    it "returns false, if not assigned" do
      expect(ApplicationHelper.barcode_assigned?(valid_barcode)).to eq false
    end
    it "prevents barcode re-use" do
      bin
      expect{ box }.to raise_error "Validation failed: Mdpi barcode #{valid_barcode} has already been assigned to a Bin"
    end
    it "returns false, if 0" do
      expect(ApplicationHelper.barcode_assigned?(0)).to eq false
    end
  end

  describe "::dp_na(field)" do
    before(:each) { @tm = physical_object.ensure_tm }
    it "returns nil value for required field" do
      expect(dp_na(:filename)).to be_nil
    end
    it "returns nil value for optional field" do
      expect(dp_na(:comments)).to be_nil
    end
    it "returns true value for na field" do
      expect(dp_na(:baking)).to eq true
    end
  end

  describe "::dp_requirement(field)" do
    before(:each) { @tm = physical_object.ensure_tm }
    it "returns string value for required field" do
      expect(dp_requirement(:filename)).not_to be_blank
    end
    it "returns nil value for optional field" do
      expect(dp_requirement(:comments)).to be_blank
    end
    it "returns nil value for na field" do
      expect(dp_requirement(:baking)).to be_blank
    end
  end

  describe "#environment_notice" do
    it "returns an environment notice string" do
      expect(helper.environment_notice).to be_a String
      if Rails.env.production?
        expect(helper.environment_notice).to be_blank
      else
        expect(helper.environment_notice).to match Rails.env.capitalize
        expect(helper.environment_notice).to match /Environment/
      end
    end
  end

  describe "#hashify(array)" do
    let(:array) { [:foo, :bar] }
    let(:hash) { { "foo" => "foo", "bar" => "bar" } }
    it "returns a hash of reflexive string values" do
      expect(helper.hashify(array)).to eq hash
    end
  end

  describe "#normalize_dates" do
    let(:string_value) { "02/03/2001" }
    let(:time_value) { DateTime.strptime(string_value, "%m/%d/%Y") }
    before(:each) do
      params = { digital_provenance:
        { cleaning_date: string_value,
          baking: string_value,
          digital_file_provenances_attributes:
            { "0" => { date_digitized: string_value },
              "1" => { date_digitized: string_value }
          }
        }
      }
      allow(helper).to receive(:params).and_return(params)
    end
    describe "it converts date strings to DateTime values:"  do
      [:cleaning_date, :baking].each do |att|
        specify att do
          expect(helper.send(:params)[:digital_provenance][att]).to eq string_value
          helper.normalize_dates
          expect(helper.send(:params)[:digital_provenance][att]).to eq time_value
        end
      end
      specify "digital_file_provenances_attributes: date_digitized" do
        helper.send(:params)[:digital_provenance][:digital_file_provenances_attributes].each do |key, att_hash|
          expect(att_hash[:date_digitized]).to eq string_value
        end
        helper.normalize_dates
        helper.send(:params)[:digital_provenance][:digital_file_provenances_attributes].each do |key, att_hash|
          expect(att_hash[:date_digitized]).to eq time_value
        end
      end
    end
  end

end
