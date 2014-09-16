require 'rails_helper'

describe PicklistSpecificationsController do
  render_views
  before(:each) { sign_in }
  let(:picklist_specification) { FactoryGirl.create(:picklist_specification, :cdr) }
  let(:valid_picklist_specification) { FactoryGirl.build(:picklist_specification, :cdr) }
  let(:invalid_picklist_specification) { FactoryGirl.build(:invalid_picklist_specification, :cdr) }
  let(:picklist) { FactoryGirl.create(:picklist) }

  describe "GET index" do
    before(:each) do
      picklist
      picklist_specification
      get :index
    end
    it "assigns all picklist_specification specs to @picklist_specs" do
      expect(assigns(:picklist_specs)).to eq [picklist_specification]
    end
    it "assigns all picklists to @picklists" do
      expect(assigns(:picklists)).to eq [picklist]
    end
    it "renders :index" do
      expect(response).to render_template :index
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: picklist_specification.id, format: :html }
    it "assigns the requested picklist_specification spec to @ps" do
      expect(assigns(:ps)).to eq picklist_specification
    end
    it "assigns tm to @tm" do
      expect(assigns(:tm)).to eq picklist_specification.technical_metadatum.as_technical_metadatum
    end
    it "renders the :show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET new" do
    before(:each) { get :new }
    it "assigns a new object to @ps" do
      expect(assigns(:ps)).to be_a_new(PicklistSpecification)
    end
    it "renders the :new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: picklist_specification.id }
    it "locates the requested object" do
      expect(assigns(:ps)).to eq picklist_specification
    end
    it "renders the :edit template" do
      expect(response).to render_template(:edit) 
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, ps: valid_picklist_specification.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "saves the new object in the database" do
        expect{ creation }.to change(PicklistSpecification, :count).by(1)
      end
      it "redirects to the picklist_specification specifications" do
        creation
        expect(response).to redirect_to(controller: :picklist_specifications, action: :index) 
      end
    end

    context "with invalid attributes" do
      let(:creation) { post :create, ps: invalid_picklist_specification.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "does not save the new object in the database" do
        expect{ creation }.not_to change(PicklistSpecification, :count)
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
        put :update, id: picklist_specification.id, ps: FactoryGirl.attributes_for(:picklist_specification, name: "Updated Test Picklist Specification"), tm: FactoryGirl.attributes_for(:cdr_tm)
      end

      it "locates the requested object" do
        expect(assigns(:ps)).to eq picklist_specification
      end
      it "changes the object's attributes" do
        expect(picklist_specification.name).not_to eq "Updated Test Picklist Specification"
        picklist_specification.reload
        expect(picklist_specification.name).to eq "Updated Test Picklist Specification"
      end
      it "redirects to the picklist_specification specficications index" do
        expect(response).to redirect_to(controller: :picklist_specifications, action: :index) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: picklist_specification.id, ps: FactoryGirl.attributes_for(:invalid_picklist_specification), tm: FactoryGirl.attributes_for(:cdr_tm)
      end

      it "locates the requested object" do
        expect(assigns(:ps)).to eq picklist_specification
      end
      it "does not change the object's attributes" do
        expect(picklist_specification.description).not_to eq "Invalid picklist_specification description"
        picklist_specification.reload
        expect(picklist_specification.description).not_to eq "Invalid picklist_specification description"
      end
      it "re-renders the :edit template" do
        expect(response).to render_template(:edit)
      end

    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: picklist_specification.id }
    it "deletes the object" do
      picklist_specification
      expect{ deletion }.to change(PicklistSpecification, :count).by(-1)
    end
    it "redirects to the picklist_specification specifications index" do
      deletion
      expect(response).to redirect_to picklist_specifications_path
    end
  end

  #query
  #query_add
  #picklist_list
  #new_picklist

end
