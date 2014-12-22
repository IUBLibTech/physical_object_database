require 'rails_helper'

describe DatTm do

  let(:dat_tm) {FactoryGirl.build :dat_tm }

  it "gets a valid object from FactoryGirl" do
    expect(dat_tm).to be_valid
  end

  #no required fields

  describe "has optional fields" do
    specify "format_duration" do
      dat_tm.format_duration = nil
      expect(dat_tm).to be_valid
    end
    specify "tape_stock_brand" do
      dat_tm.tape_stock_brand = nil
      expect(dat_tm).to be_valid
    end
  end

  it_behaves_like "includes technical metadatum behaviors", FactoryGirl.build(:dat_tm) 

  describe "#master_copies" do
    it "returns 1" do
      expect(dat_tm.master_copies).to eq 1
    end
  end

end

