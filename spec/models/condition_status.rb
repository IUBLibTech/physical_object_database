require 'rails_helper'

describe ConditionStatus do
  let(:condition_status) { FactoryGirl.create(:condition_status) }

  it "requires a condition_status_template" do
    condition_status.condition_status_template = nil
    expect(condition_status).not_to be_valid
  end

  it "requires a username" do
    condition_status.user = nil
    expect(condition_status).not_to be_valid
  end

end
