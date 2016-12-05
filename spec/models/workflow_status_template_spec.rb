describe WorkflowStatusTemplate do
  # need to manually destroy after each creation, as this is a seed data table
  let(:workflow_status_template) { FactoryGirl.create(:workflow_status_template) }
  let(:valid_workflow_status_template) { FactoryGirl.build(:workflow_status_template) }
  let(:invalid_workflow_status_template) { FactoryGirl.build(:workflow_status_template, :invalid) }

  describe "should be seeded with data:" do
    seeded_values = { "Batch" => 6, "Bin" => 5, "Physical Object" => 7 }
    seeded_values.each do |object_type, count|
      it "#{count} #{object_type} status_templates" do
        expect(WorkflowStatusTemplate.where(object_type: object_type).size).to eq count
      end
    end
  end

  describe "FactoryGirl" do
    it "provides a valid object" do
      expect(valid_workflow_status_template).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_workflow_status_template).not_to be_valid
    end
  end

  describe "has required fields:" do
    it "name" do
      valid_workflow_status_template.name = nil
      expect(valid_workflow_status_template).not_to be_valid
    end
    
    it "unique name (for scope of same object type)" do
      workflow_status_template
      expect(valid_workflow_status_template).not_to be_valid
      workflow_status_template.destroy
    end
  
    it "allows duplicate names (for different object types)" do
      workflow_status_template
      valid_workflow_status_template.object_type = "Bin"
      expect(valid_workflow_status_template).to be_valid
      workflow_status_template.destroy
    end

    it "object type" do
      valid_workflow_status_template.object_type = nil
      expect(valid_workflow_status_template).not_to be_valid
    end

    specify "object_type in allowed list" do
      valid_workflow_status_template.object_type = "invalid value"
      expect(valid_workflow_status_template).not_to be_valid
    end

    it "sequence index" do
      valid_workflow_status_template.sequence_index = nil
      expect(valid_workflow_status_template).not_to be_valid
    end
  end

  describe "has optional fields:" do
    it "description" do
      valid_workflow_status_template.description = nil
      expect(valid_workflow_status_template).to be_valid
    end
  end

  describe "supports object types:" do
    let(:object_types) { valid_workflow_status_template.object_types }
    ["Batch", "Bin", "Physical Object"].each do |object_type|
      specify "#{object_type}" do
        expect(object_types[object_type]).not_to be_nil
      end
    end
    it "3 total" do
      expect(object_types.size).to eq 3
    end
  end

  describe "has relationships:" do
    it "many workflow_statuses" do
      expect(valid_workflow_status_template.workflow_statuses.size).to eq 0 
    end
  end

  describe ".select_options(object_type)" do
    let(:select_options) { WorkflowStatusTemplate.select_options(workflow_status_template.object_type) }
    it "returns name/name hash" do
      expect(select_options[workflow_status_template.name]).to eq workflow_status_template.name
      workflow_status_template.destroy
    end
  end

  describe ".template_by_status_name(object_type, name)" do
    it "returns matching template" do
      expect(WorkflowStatusTemplate.template_by_status_name("Physical Object", "Boxed")).to eq WorkflowStatusTemplate.where(object_type: "Physical Object", name: "Boxed").first
    end
  end  
end
