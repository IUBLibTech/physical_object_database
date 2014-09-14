require 'rails_helper'

describe OpenReelTm do

  let(:open_reel_tm) {FactoryGirl.build :open_reel_tm }

  it "gets a valid object from FactoryGirl" do
    expect(open_reel_tm).to be_valid
  end

  describe "has required fields:" do
    specify "pack deformation" do
      open_reel_tm.pack_deformation = nil
      expect(open_reel_tm).not_to be_valid
    end
    specify "pack deformation in values list" do
      open_reel_tm.pack_deformation = "invalid value"
      expect(open_reel_tm).not_to be_valid
    end
    specify "reel_size" do
      open_reel_tm.reel_size = nil
      expect(open_reel_tm).not_to be_valid
    end
    specify "reel_size in values list" do
      open_reel_tm.reel_size = "invalid value"
      expect(open_reel_tm).not_to be_valid
    end
  end

  describe "has optional fields:" do
    specify "tape stock brand" do
      open_reel_tm.tape_stock_brand = nil
      expect(open_reel_tm).to be_valid
    end
  end

  it_behaves_like "includes technical metadatum behaviors", FactoryGirl.build(:open_reel_tm) 

end

