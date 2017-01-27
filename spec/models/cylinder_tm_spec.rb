describe CylinderTm do

  let(:cylinder_tm) {FactoryGirl.build :cylinder_tm }

  it "gets a valid object from FactoryGirl" do
    expect(cylinder_tm).to be_valid
  end

  describe "has optional fields:" do
    [:playback_speed, :fragmented, :repaired_break, :cracked, :damaged_core, :fungus, :efflorescence, :other_contaminants].each do |att|
      specify "#{att}" do
        cylinder_tm.send("#{att}=", nil)
        expect(cylinder_tm).to be_valid
      end
    end
  end

  describe "has select fields, with value lists:" do
    [:size, :material, :groove_pitch, :recording_method].each do |att|
      specify "#{att}" do
        cylinder_tm.send("#{att}=", 'invalid value')
        expect(cylinder_tm).not_to be_valid
      end
    end
  end

  it_behaves_like "includes TechnicalMetadatumModule", FactoryGirl.build(:cylinder_tm) 

  describe "#master_copies" do
    it "returns 1" do
      expect(cylinder_tm.master_copies).to eq 1
    end
  end

  describe "manifest export" do
    specify "has desired headers" do
      expect(cylinder_tm.manifest_headers).to eq []
    end
  end

end

