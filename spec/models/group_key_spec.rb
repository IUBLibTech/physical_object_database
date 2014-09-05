require 'rails_helper'

describe GroupKey do
  let(:group_key) { FactoryGirl.create(:group_key) }
  let(:valid_group_key) { FactoryGirl.build(:group_key) }
  let(:valid_po) { FactoryGirl.build(:physical_object, :cdr, group_key: valid_group_key) }

  describe "has relationships:" do
    it "can have physical objects" do
      expect(valid_group_key.physical_objects).to be_empty
    end
    it "caches physical objects count" do
      expect(valid_group_key.physical_objects_count).to eq 0
    end
  end

  describe "has virtual attributes:" do
    describe "#group_identifier" do
      it "returns error message if no objects in group" do
        expect(valid_group_key.group_identifier).to eq "ERROR_NO_OBJECTS_IN_GROUP"
      end
      it "returns error message if no object in first position" do
        valid_po.group_position = 2
        valid_po.save
        expect(valid_group_key.group_identifier).to eq "ERROR_NO_OBJECT_IN_FIRST_POSITION"
      end
      it "returns first object's group identifier" do
        valid_po.save
        expect(valid_group_key.group_identifier).to eq valid_po.group_identifier
      end
    end
    describe "spreadsheet_descriptor" do
      it "returns the group_identifier value" do
        expect(valid_group_key.spreadsheet_descriptor).to eq valid_group_key.group_identifier
      end
    end
  end
end
