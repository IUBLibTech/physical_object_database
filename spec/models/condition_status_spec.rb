describe ConditionStatus do
  let(:condition_status) { FactoryGirl.create(:condition_status, :physical_object) }
  let(:valid_condition_status) { FactoryGirl.build(:condition_status, :physical_object) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr) }

  it "gets a valid object from FactoryGirl" do
    expect(valid_condition_status).to be_valid
  end

  describe "has required fields:" do
  
    specify "condition_status_template" do
      condition_status.condition_status_template = nil
      expect(condition_status).not_to be_valid
    end

    specify "condition_status_template unique for a given physical_object" do
      condition_status.physical_object = physical_object
      condition_status.save
      condition_status.reload
      valid_condition_status.physical_object = physical_object
      valid_condition_status.condition_status_template = condition_status.condition_status_template
      expect(valid_condition_status).not_to be_valid
    end

    specify "condition_status_template unique for a given bin" do
      skip "No condition statuses defined yet for Bins"
    end

    specify "condition_status_template duplicate allowed for different physical_object,bin" do
      condition_status.physical_object = physical_object
      condition_status.save
      condition_status.reload
      valid_condition_status.bin = bin
      expect(valid_condition_status).to be_valid
    end
  
    specify "user" do
      condition_status.user = nil
      expect(condition_status).not_to be_valid
    end

  end

  describe "active attribute" do
    it "status is active on create" do
      expect(condition_status.active).to eq true
      condition_status.active = false
      expect(condition_status.active).to eq false
    end
  end

  describe "has relationships:" do
    it "can belong to a physical object" do
      expect(valid_condition_status.physical_object).to be_nil
    end
    it "can belong to a bin" do
      expect(valid_condition_status.bin).to be_nil
    end
  end

   describe "has virtual attributes:" do
    it "name returns condition_status_template name" do
      expect(valid_condition_status.name).to eq valid_condition_status.condition_status_template.name
    end
    it "description returns condition_status_template_name" do
      expect(valid_condition_status.description).to eq valid_condition_status.condition_status_template.description
    end
    specify "condition_note returns note" do
      valid_condition_status.notes = "note text"
      expect(valid_condition_status.condition_note).to eq valid_condition_status.notes
    end
    describe "#blocks_packing" do
      context "when there is no associated template" do
        before(:each) { valid_condition_status.condition_status_template = nil }
        it "returns nil" do
          expect(valid_condition_status.blocks_packing).to be_nil
        end
      end
      context "when there is an associated template" do
        before(:each) { expect(valid_condition_status.condition_status_template).not_to be_nil }
        it "returns template block_packing? value" do
          expect(valid_condition_status.blocks_packing).to eq valid_condition_status.condition_status_template.blocks_packing?
        end
      end
    end
  end

  include_examples "default_values examples", {active: true} do
    let(:target_object) { valid_condition_status }
  end

  describe "scopes" do
    describe "blocking" do
      before(:each) do
        [{ active: true, condition_status_template_id: ConditionStatusTemplate.where(blocks_packing: true).first.id },
         { active: false, condition_status_template_id: ConditionStatusTemplate.where(blocks_packing: true).last.id },
         { active: true, condition_status_template_id: ConditionStatusTemplate.where(blocks_packing: false).first.id },
         { active: false, condition_status_template_id: ConditionStatusTemplate.where(blocks_packing: false).last.id }].each do |values_hash|
          cs = physical_object.condition_statuses.new
          cs.assign_attributes(values_hash)
          cs.save!
        end
      end
      it "returns active, blocking records" do
        expect(physical_object.condition_statuses.size).to eq 4
        expect(physical_object.condition_statuses.blocking.size).to eq 1
        expect(physical_object.condition_statuses.blocking).to eq [physical_object.condition_statuses.first]
      end
    end
  end

  include_examples "has user field" do
    let(:target_object) { valid_condition_status }
  end

  include_examples "includes XMLExportModule", :notes, :active do
    let(:target_object) { valid_condition_status }
  end
 
end
