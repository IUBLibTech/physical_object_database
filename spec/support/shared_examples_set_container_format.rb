#
# requires let statements for:
# container
# contained

shared_examples "sets container format" do # for container, contained
  it "sets container format" do
    expect(container.format).to be_blank
    contained.set_container_format
    expect(container.format).not_to be_blank
    expect(container.format).to eq contained.format
  end
end
shared_examples "nil and blank format cases" do # for container, contained
  context "(with nil format)" do
    before(:each) { container.format = nil }
    include_examples "sets container format"
  end
  context "(with blank format)" do
    before(:each) { container.format = '' }
    include_examples "sets container format"
  end
end
