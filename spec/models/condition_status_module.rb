require 'rails_helper'

describe ConditionStatusModule do
  let(:module_class) { Class.new { include ConditionStatusModule } }
  let(:module_object) { module_class.new }

  describe "#class_title" do
    it "returns class title text" do
      expect(module_object.class_title).not_to be_blank
    end
  end

  describe "#condition_status_options" do
    it "returns select_options for object type"
  end

  describe ".has_condition?(object, status_name)" do
    it "returns true/false for status_name present for object class as object type"
  end

end
