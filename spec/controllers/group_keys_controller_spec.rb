require 'rails_helper'

describe GroupKeysController do
  render_views
  before(:each) { sign_in }
  let(:valid_group_key) { FactoryGirl.build(:group_key) }
  let(:invalid_group_key) { FactoryGirl.build(:invalid_group_key) }
  let(:group_key) { FactoryGirl.create(:group_key) }
  let(:group_keyed_object) { FactoryGirl.create(:physical_object, :cdr, group_key: group_key) }
  let(:ungrouped_object) { FactoryGirl.create(:physical_object, :cdr, :barcoded, group_key: nil) }

  describe "FactoryGirl creation" do
    specify "makes a valid group key" do
      expect(valid_group_key).to be_valid
    end
    specify "makes an invalid group_key" do
      expect(invalid_group_key).to be_invalid
    end
  end

  describe "GET index" do
    before(:each) do
      group_key
      get :index
    end
    it "assigns @group_keys" do
      expect(assigns(:group_keys)).to eq [group_key]
    end
    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET show" do
    before(:each) do
      group_key
      group_keyed_object
      get :show, id: group_key.id
    end
    it "assigns the requested object to @group_key" do
      expect(assigns(:group_key)).to eq group_key
    end
    it "assigns group_keyed @physical_objects" do
      expect(assigns(:physical_objects)).to eq [group_keyed_object]
    end
    include_examples "provides pagination", :physical_objects
    it "renders the :show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET new" do
    before(:each) { get :new }
    it "assigns @group_key" do
      expect(assigns(:group_key)).to be_a_new GroupKey
    end
    it "assigns @edit_mode to true" do
      expect(assigns(:edit_mode)).to eq true
    end
    it "assigns @action to create" do
      expect(assigns(:action)).to eq "create"
    end
    it "assigns @submit_text" do
      expect(assigns(:submit_text)).to eq "Create Group Key"
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: group_key.id }
    it "assigns @group_key" do
      expect(assigns(:group_key)).to eq group_key
    end
    it "assigns @edit_mode to true" do
      expect(assigns(:edit_mode)).to eq true
    end
    it "assigns @action to update" do
      expect(assigns(:action)).to eq "update"
    end
    it "assigns @submit_text" do
      expect(assigns(:submit_text)).to eq "Update Group Key"
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, group_key: valid_group_key.attributes.symbolize_keys }
      it "saves the new object in the database" do
        expect{ creation }.to change(GroupKey, :count).by(1)
      end
      it "redirects to the object" do
        creation
        expect(response).to redirect_to assigns(:group_key)
      end
    end
    context "with invalid attributes" do
      let(:creation) { post :create, group_key: invalid_group_key.attributes.symbolize_keys }
      it "does not save the new object in the database" do
        expect{ creation }.not_to change(GroupKey, :count)
      end
      it "re-renders the :new template" do
        creation
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT update" do
    context "with valid attributes" do
      before(:each) do
        put :update, id: group_key.id, group_key: FactoryGirl.attributes_for(:group_key, group_total: 42)
      end
      it "locates the requested object" do
        expect(assigns(:group_key)).to eq group_key
      end
      it "changes the object's attributes" do
        expect(group_key.group_total).to eq 1
        group_key.reload
        expect(group_key.group_total).to eq 42
      end
      it "redirects to the updated object" do
        expect(response).to redirect_to(action: :show) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: group_key.id, group_key: FactoryGirl.attributes_for(:invalid_group_key)
      end
      it "locates the requested object" do
        expect(assigns(:group_key)).to eq group_key
      end
      it "does not change the object's attributes" do
        group_key.reload
	expect(group_key.group_total).not_to be_nil
      end
      it "re-renders the edit template" do
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: group_key.id }
    it "deletes the object" do
      group_key
      expect{ deletion }.to change(GroupKey, :count).by(-1)
    end
    it "redirects to the group_keys index" do
      deletion
      expect(response).to redirect_to group_keys_path
    end
    it "retains and disassociates remaining physical objects" do
      original_id = group_keyed_object.group_key_id
      expect{ deletion }.not_to change(PhysicalObject, :count)
      group_keyed_object.reload
      expect(group_keyed_object.group_key).not_to be_nil
      expect(group_keyed_object.group_key_id).not_to eq original_id
    end
  end

  describe "PATCH reorder" do
    before(:each) { request.env["HTTP_REFERER"] = "source_page" }
    it "flashes inaction message if no ids are passed" do
      patch :reorder, id: group_key.id
      expect(flash[:notice]).to match /no change/i
    end
    it "reorders the objects" do
      group_keyed_object
      second_object = group_keyed_object.dup
      second_object.group_position = 2
      second_object.save
      reorder_submission = "#{second_object.id},#{group_keyed_object.id}"
      patch :reorder, id: group_key.id, reorder_submission: reorder_submission
      group_keyed_object.reload
      second_object.reload
      expect(flash[:notice]).to match /success/i
      expect(second_object.group_position).to eq 1
      expect(group_keyed_object.group_position).to eq 2
    end
    it "retains gaps" do
      group_keyed_object
      second_object = group_keyed_object.dup
      second_object.group_position = 3
      second_object.save
      reorder_submission = "#{second_object.id},,#{group_keyed_object.id}"
      patch :reorder, id: group_key.id, reorder_submission: reorder_submission
      group_keyed_object.reload
      second_object.reload
      expect(flash[:notice]).to match /success/i
      expect(second_object.group_position).to eq 1
      expect(group_keyed_object.group_position).to eq 3
    end
    it "redirects to :back" do
      patch :reorder, id: group_key.id
      expect(response).to redirect_to "source_page"
    end
  end

  describe "PATCH include" do
    before(:each) { request.env["HTTP_REFERER"] = "source_page" }
    let(:patch_include) { patch :include, id: group_key.id, mdpi_barcode: mdpi_barcode, group_position: group_position }
    let(:group_position) { 42 }
    context "with a blank barcode" do
      let(:mdpi_barcode) { "" }
      it "flashes a failure warning" do
        patch_include
	expect(flash[:warning]).not_to be_blank
      end
      it "redirects to :back" do
        patch_include
        expect(response).to redirect_to "source_page"
      end
    end
    context "with a non-matching barcode" do
      let(:mdpi_barcode) { 42 }
      it "flashes a failure warning" do
        patch_include
	expect(flash[:warning]).not_to be_blank
      end
      it "redirects to :back" do
        patch_include
        expect(response).to redirect_to "source_page"
      end
    end
    context "with a matching barcode" do
      let(:mdpi_barcode) { ungrouped_object.mdpi_barcode }
      context "emptying the former group" do
        it "changes the object's group and position" do
	  patch_include
	  ungrouped_object.reload
	  expect(ungrouped_object.group_key).to eq group_key
	  expect(ungrouped_object.group_position).to eq group_position
	end
        it "destroys the original group" do
	  group_keyed_object
	  ungrouped_object
	  expect{ patch_include }.to change(GroupKey, :count).by(-1)
	end
        it "redirects to :back" do
	  patch_include
	  expect(response).to redirect_to "source_page"
	end
      end
      context "NOT emptying the former group" do
        let!(:sibling_object) { FactoryGirl.create :physical_object, :cdr, group_key: ungrouped_object.group_key }
        it "changes the object's group and position" do
          patch_include
          ungrouped_object.reload
          expect(ungrouped_object.group_key).to eq group_key
          expect(ungrouped_object.group_position).to eq group_position
        end
        it "does NOT destroy the original group" do
          group_keyed_object
          ungrouped_object
          expect{ patch_include }.not_to change(GroupKey, :count)
        end
        it "redirects to :back" do
          patch_include
          expect(response).to redirect_to "source_page"
        end
      end
    end
  end
  
end
