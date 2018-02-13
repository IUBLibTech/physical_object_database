describe "physical_objects" do

  it "routes to download_spreadsheet_example" do
    expect(get("/physical_objects/download_spreadsheet_example")).to be_routable
  end

  it "routes to tm_form" do
    expect(get("/physical_objects/tm_form")).to be_routable
  end

  it "routes to workflow_history" do
    expect(get("/physical_objects/:id/workflow_history")).to be_routable
  end

  it "routes to split_show" do
    expect(get("/physical_objects/:id/split_show")).to be_routable
  end

  it "routes to upload_show" do
    expect(get("/physical_objects/upload_show")).to be_routable
  end

  it "routes to has_ephemera" do
    expect(get("/physical_objects/has_ephemera")).to be_routable
  end

  it "routes to is_archived" do
    expect(get("/physical_objects/is_archived")).to route_to("physical_objects#is_archived")
  end

  it "routes to split_update" do
    expect(patch("/physical_objects/:id/split_update")).to be_routable
  end

  it "routes to upload_update" do
    expect(post("/physical_objects/upload_update")).to be_routable
  end

  it "routes to unbin" do
    expect(post("/physical_objects/:id/unbin")).to be_routable
  end

  it "routes to unbox" do
    expect(post("/physical_objects/:id/unbox")).to be_routable
  end

  it "routes to unpick" do
    expect(post("/physical_objects/:id/unpick")).to be_routable
  end

  it "routes to ungroup" do
    expect(post("/physical_objects/:id/ungroup")).to be_routable
  end

  it "routes to edit_ephemera" do
    expect(get: "/physical_objects/1/edit_ephemera").to route_to("physical_objects#edit_ephemera", id: "1")
  end

  it "routes to update_ephemera" do
    expect(patch: "/physical_objects/1/update_ephemera").to route_to("physical_objects#update_ephemera", id: "1")
  end

  it "routes to contained" do
    expect(get "/physical_objects/contained").to route_to action: "contained", controller: "physical_objects"
  end

  it "routes to generate_filename" do
   expect(get "/physical_objects/1/generate_filename").to route_to("physical_objects#generate_filename", id: "1")
  end

  it 'routes to invert_group_position' do
    expect(post('/physical_objects/1/invert_group_position')).to route_to('physical_objects#invert_group_position', id: '1')
  end

  it 'routes to cylinder_preload_edit' do
    expect(get('/physical_objects/1/cylinder_preload_edit')).to route_to('physical_objects#cylinder_preload_edit', id: '1')
  end

  it 'routes to cylinder_preload_update' do
    expect(patch('/physical_objects/1/cylinder_preload_update')).to route_to('physical_objects#cylinder_preload_update', id: '1')
  end
end
