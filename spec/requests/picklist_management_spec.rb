describe "Picklist management" do
  let(:picklist) { FactoryBot.create(:picklist) }
  before(:each) do 
    sign_in
  end
  #no index template
  it "renders new template" do
    get "/picklists/new"
    expect(response).to render_template :new
  end
  it "renders show template" do
    get "/picklists/#{picklist.id}"
    expect(response).to render_template :show
  end
  it "renders edit template" do
    get "/picklists/#{picklist.id}/edit"
    expect(response).to render_template :edit
  end

end
