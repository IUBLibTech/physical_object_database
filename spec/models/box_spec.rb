require 'rails_helper'

describe Box do

  let(:bin) { FactoryGirl.create :bin}
  let(:box) { FactoryGirl.create :box, bin: bin }
  let(:po) { FactoryGirl.create :physical_object, :cdr, box: box}

  it "gets a valid object from FactoryGirl" do
    expect(box).to be_valid
  end

  describe "has relationships:" do
    it "has many physical_objects" do 
  	  expect(box.physical_objects).to be_empty	
  	  po # a reference to the physcical object is necessary to "load" it into the rspec framework
  	  expect(box.physical_objects).not_to be_empty
  	  expect(box.physical_objects_count).to eq 1   	
    end
    it "can belong to a bin" do
  	  expect(box.bin).to eq(bin)
  	  box.bin = nil
  	  expect(box.bin).to be_nil
  	  box.save
  	  expect(bin.boxes.where(id: box.id).first).to eq nil
    end
    it "can belong to a spreadsheet" do
      expect(box.spreadsheet).to be_nil
    end
  end

  it "has a barcode" do
  	expect(box.mdpi_barcode).not_to be_nil
  end

  it "provides a spreadsheet descriptor" do
  	expect(box.spreadsheet_descriptor).to eq(box.mdpi_barcode)
  end

  it "provides a physical object count" do
    expect(box.physical_objects_count).to eq 0 
  end

end

