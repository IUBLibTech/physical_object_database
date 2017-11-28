describe StagingPercentage do
  let(:valid_sp) { FactoryBot.build :staging_percent }
  let(:invalid_sp) { FactoryBot.build :staging_percent, :invalid }
  let(:sp) { FactoryBot.create :sp }

  describe "FactoryBot" do
    it "provides a valid object" do
      expect(valid_sp).to be_valid
    end
    it "provides a invalid object" do
      expect(invalid_sp).not_to be_valid
    end
  end
  describe "has attributes" do
    describe "format" do
      it "is required" do
        valid_sp.format = nil
        expect(valid_sp).not_to be_valid
      end
    end
    [:memnon_percent, :iu_percent].each do |att|
      describe att do
        it "is required" do
          valid_sp[att] = nil
          expect(valid_sp).not_to be_valid
        end
        it "must be an integer" do
          valid_sp[att] = 42.42
          expect(valid_sp).not_to be_valid
        end
        describe "must be in 0..100 range" do
          it "cannot be negative" do
            valid_sp[att] = -42
            expect(valid_sp).not_to be_valid
          end
          it "cannot be >100" do
            valid_sp[att] = 142
            expect(valid_sp).not_to be_valid
          end
          it "can be in 0..100 range" do
            valid_sp[att] = 42
            expect(valid_sp).to be_valid
          end
        end
      end
    end
  end

  describe ".default_percentage" do
    it "returns 10" do
      expect(StagingPercentage.default_percentage).to eq 10
    end
  end

end
