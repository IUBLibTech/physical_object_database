describe Note do
  let(:note) { FactoryBot.create(:note) }
  let(:valid_note) { FactoryBot.build(:note) }

  it "gets a valid object from FactoryBot" do
    expect(valid_note).to be_valid
  end

  it "requires a username" do
    valid_note.user = nil
    expect(valid_note).to be_invalid
  end

  it "allows body text" do
    valid_note.body = ""
    expect(valid_note).to be_valid
  end

  it "allows export" do
    valid_note.export = false
    expect(valid_note).to be_valid
  end

  include_examples "has user field" do
    let(:target_object) { valid_note }
  end

  include_examples "includes XMLExportModule", :body, :export do
    let(:target_object) { valid_note }
  end

end
