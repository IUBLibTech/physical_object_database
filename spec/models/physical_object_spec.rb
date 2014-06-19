require 'rails_helper'

describe PhysicalObject do

  let(:po) { FactoryGirl.create :physical_object, :cdr }

  it "should require a format" do
    expect(po.format).not_to be_blank
    po.format = ""
    expect(po).to be_invalid
  end

  it "should require a unit" do
    expect(po.unit).not_to be_nil
    po.unit = nil
    expect(po).to be_invalid
  end

end
