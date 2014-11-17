require 'rails_helper'

describe GroupKey do
  let(:group_key) { FactoryGirl.create(:group_key) }
  let(:valid_group_key) { FactoryGirl.build(:group_key) }
  let(:grouped_physical_object) { FactoryGirl.create(:physical_object, :cdr, group_key: group_key) }
  let(:ungrouped_physical_object) { FactoryGirl.create(:physical_object, :cdr, group_key: nil) }

  describe "has attributes:" do
    describe "group_total" do
      it "defaults to 1" do
        expect(valid_group_key.group_total).to eq 1
      end
      it "is resettable" do
        valid_group_key.group_total = 42
        expect(valid_group_key.group_total).to eq 42
      end
      it "is required" do
        valid_group_key.group_total = nil
	expect(valid_group_key).not_to be_valid
      end
      it "must be non-negative" do
        valid_group_key.group_total = -1
	expect(valid_group_key).not_to be_valid
      end
    end
  end

  describe "has relationships:" do
    it "can have physical objects" do
      expect(group_key.physical_objects).to be_empty
      grouped_physical_object
      expect(group_key.physical_objects).not_to be_empty
    end
    it "provides physical objects count" do
      expect(group_key.physical_objects_count).to eq 0
    end
    it "retains physical objects when destroyed" do
      grouped_physical_object
      expect{ group_key.destroy }.not_to change(PhysicalObject, :count)
    end
    specify "orphaned physical objects get new group key automatically" do
      original_id = grouped_physical_object.group_key_id
      group_key.destroy
      grouped_physical_object.reload
      expect(grouped_physical_object.group_key).not_to be_nil
      expect(grouped_physical_object.group_key_id).not_to eq original_id
    end
  end

  describe "has virtual attributes:" do
    describe "#group_identifier" do
      it "returns error message if no objects in group" do
        expect(group_key.group_identifier).to eq "GR" + group_key.id.to_s.rjust(8, "0")
      end
    end
    describe "spreadsheet_descriptor" do
      it "returns the group_identifier value" do
        expect(group_key.spreadsheet_descriptor).to eq group_key.group_identifier
      end
    end
  end

  #class methods
  describe "has class methods:" do
    describe "::per_page" do
      it "should be 50" do
        expect(GroupKey.per_page).to eq 50
      end
    end
  end

end
