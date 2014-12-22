require 'rails_helper'

describe "root" do
  it "routes to physical_objects#index" do
    expect(get("/")).to route_to("physical_objects#index")
  end
end

describe "batches" do
  it "routes to workflow_history" do
    expect(get("/batches/:id/workflow_history")).to be_routable
  end
  it "routes to add_bin" do
    expect(patch("/batches/id/add_bin")).to be_routable
  end
  it "routes to remove_bin" do
    expect(post("/batches/id/remove_bin")).to be_routable
  end
end

describe "bins" do
  it "routes to add_barcode_item" do
    expect(post("/bins/:id/add_barcode_item")).to be_routable
  end

  it "routes to unbatch" do
    expect(post("/bins/:id/unbatch")).to be_routable
  end

  it "routes to unseal" do
    expect(post("/bins/:id/unseal")).to be_routable
  end

  it "routes to show_boxes" do
    expect(get("/bins/:id/show_boxes")).to be_routable
  end

  it "routes to assign_boxes" do
    expect(patch("/bins/:id/assign_boxes")).to be_routable
  end

  it "routes to workflow_history" do
    expect(get("/bins/:id/workflow_history")).to be_routable
  end

end

describe "boxes" do
  it "routes to edit" do
    expect(get("/boxes/:id/edit")).to be_routable
  end

  it "routes to add_barcode_item" do
    expect(post("/boxes/:id/add_barcode_item")).to be_routable
  end

  it "routes to unbin" do
    expect(post("/boxes/:id/unbin")).to be_routable
  end

  it "routes to index through bins" do
    expect(post("/bins/:bin_id/boxes")).to be_routable
  end

  it "routes to new through bins" do
    expect(get("/bins/:bin_id/boxes/new")).to be_routable
  end

  it "routes to create through bins" do
    expect(post("/bins/:bin_id/boxes")).to be_routable
  end
end

describe "group keys" do
  it "routes to index" do
    expect(get "/group_keys").to route_to action: "index", controller: "group_keys"
  end
  it "routes to show" do
    expect(get "/group_keys/:id").to route_to action: "show", controller: "group_keys", id: ":id"
  end
  it "routes to new" do
    expect(get "/group_keys/new").to route_to action: "new", controller: "group_keys"
  end
  it "routes to edit" do
    expect(get("/group_keys/:id/edit")).to be_routable
  end
  it "routes to create" do
    expect(post("/group_keys")).to route_to action: "create", controller: "group_keys"
  end 
  it "routes to update" do
    expect(patch("/group_keys/:id")).to route_to action: "update", controller: "group_keys", id: ":id"
  end
  it "routes to destroy" do
    expect(delete("/group_keys/:id")).to route_to action: "destroy", controller: "group_keys", id: ":id"
  end
  it "routes to reorder" do
    expect(patch("/group_keys/:id/reorder")).to route_to action: "reorder", controller: "group_keys", id: ":id"
  end

  it "routes to physical_object new through group_keys" do
    expect(get("/group_keys/:group_key_id/physical_objects/new")).to be_routable
  end
end

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

end

describe "picklist_specifications" do
  it "routes to tm_form" do
    expect(get("/picklist_specifications/tm_form")).to be_routable
  end
  it "routes to query" do
    expect(get("/picklist_specifications/:id/query")).to be_routable
  end
  it "routes to picklist_list" do
    expect(get("/picklist_specifications/picklist_list")).to be_routable
  end
  it "routes to new_picklist" do
    expect(get("/picklist_specifications/new_picklist")).to be_routable
  end
  it "routes to query_add" do
    expect(patch("/picklist_specifications/:id/query_add")).to be_routable
  end
  it "routes to update" do
    expect(post("/picklist_specifications/:id")).to be_routable
  end
end

describe "picklists" do
  it "does not route to index" do
    expect(get("/picklists")).not_to be_routable
  end
  it "routes to process_list" do
    expect(patch("/picklists/process_list")).to be_routable
  end
  it "routes to process_list" do
    expect(get("/picklists/process_list")).to be_routable
  end
  it "routes to assign_to_container" do
    expect(patch("/picklists/assign_to_container")).to be_routable
  end
  it "routes to remove_from_container" do
    expect(patch("/picklists/remove_from_container")).to be_routable
  end
  it "routes to container_full" do
    expect(post("/picklists/container_full")).to be_routable
  end
end

describe "returns" do
  it "routes to index" do
    expect(get("/returns")).to be_routable
  end
  it "routes to returns_bins" do
    expect(get("/returns/:id/return_bins")).to be_routable
  end
  it "routes to unload_bin" do
    expect(patch("/returns/:id/unload_bin")).to be_routable
  end
  it "routes to return_bin" do
    expect(get("/returns/:id/return_bin")).to be_routable
  end
  it "routes to physical_object_missing" do
    expect(get("/returns/:id/physical_object_missing")).to be_routable
  end
  it "routes to physical_object_returned" do
    expect(patch("/returns/:id/physical_object_returned")).to be_routable
  end
  it "routes to bin_unpacked" do
    expect(patch("/returns/:id/bin_unpacked")).to be_routable
  end
  it "routes to batch_complete" do
    expect(patch("/returns/:id/batch_complete")).to be_routable
  end
end

describe "search" do
  it "routes to advanced_search" do
    expect(post("/search/advanced_search")).to be_routable
  end
  it "routes to search_results" do
    expect(post("/search/search_results")).to be_routable
  end
end

describe "status_templates" do
  it "routes to index" do
    expect(get("/status_templates")).to be_routable
  end
end


describe "signin" do
  it "routes to sessions#new" do
    expect(get("/signin")).to route_to("sessions#new")
  end
end

describe "signout" do
  it "routes to sessions#destroy" do
    expect(delete("/signout")).to route_to("sessions#destroy")
  end
end

describe "sessions" do
    it "routes to new" do
      expect(get("/sessions/new")).to be_routable
    end
    it "routes to destroy" do
      expect(delete("/sessions/:id")).to be_routable
    end
    it "routest to validate_login" do
      expect(get("/sessions/validate_login")).to be_routable
    end
end

