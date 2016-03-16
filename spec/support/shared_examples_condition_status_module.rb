# requires let statements:
#  condition_status, target_object, class_title

shared_examples "includes ConditionStatusModule" do
    it "#class_title returns object's class title" do
      expect(target_object.class_title).to eq class_title
    end
    it "#condition_status_options returns status options as name/template_id hash" do
      expect(target_object.condition_status_options).not_to be_empty
      expect(target_object.condition_status_options).to include(condition_status.name => condition_status.condition_status_template_id)
    end
    it "#has_condition(object, status_name) returns true/false for object, status_name" do
      expect(target_object.has_condition?(condition_status.name)).to be true
      expect(target_object.has_condition?("Invalid Condition Status")).to be false
    end
end
