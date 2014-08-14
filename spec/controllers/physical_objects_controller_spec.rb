require 'rails_helper'
#FIXME: refactor capybara testing to automatically include sign_in?

describe PhysicalObjectsController do
  before(:each) { sign_in("user@example.com") }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr) }

  describe "GET index" do
    before(:each) do
      get :index
    end
    it "populates an array of physical objects" do
      expect(assigns(:physical_objects)).to eq [physical_object]
    end
    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: physical_object.id }

    it "assigns the requested physical object to @physical_object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
      
    it "renders the :show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET new" do
    before(:each) { get :new }
    it "assigns a new PhysicalObject to @physical_object" do
      expect(assigns(:physical_object)).to be_a_new(PhysicalObject)
    end
    it "renders the :new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: physical_object.id }
    it "locates the requested object" do
      expect(assigns(:physical_object)).to eq physical_object
    end
    it "renders the :edit template" do
      expect(response).to render_template(:edit) 
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, physical_object: physical_object.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "saves the new physical object in the database" do
        physical_object
        expect{ creation }.to change(PhysicalObject, :count).by(1)
      end
      it "redirects to the objects index" do
        creation
        expect(response).to redirect_to(controller: :physical_objects, action: :index) 
      end
    end

    context "with invalid attributes" do
      #FIXME: test that invalid object is invalid?
      let(:creation) { post :create, physical_object: FactoryGirl.attributes_for(:invalid_physical_object, :cdr), tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "does not save the new physical object in the database" do
        physical_object
	expect{ creation }.not_to change(PhysicalObject, :count)
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
        put :update, id: physical_object.id, physical_object: FactoryGirl.attributes_for(:physical_object, :cdr, title: "Updated title"), tm: FactoryGirl.attributes_for(:cdr_tm) 
      end

      it "locates the requested object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
      it "changes the object's attributes" do
	expect(physical_object.title).not_to eq "Updated title"
        physical_object.reload
	expect(physical_object.title).to eq "Updated title"
      end
      it "redirects to the updated object" do
        expect(response).to redirect_to(controller: :physical_objects, action: :index) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: physical_object.id, physical_object: FactoryGirl.attributes_for(:invalid_physical_object, :cdr), tm: FactoryGirl.attributes_for(:cdr_tm)
      end

      it "locates the requested object" do
        expect(assigns(:physical_object)).to eq physical_object
      end
      it "does not change the object's attributes" do
        expect(physical_object.title).to eq "FactoryGirl object"
        physical_object.reload
        expect(physical_object.title).to eq "FactoryGirl object"
      end
      it "re-renders the :edit template" do
        expect(response).to render_template(:edit)
      end

    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: physical_object.id }
    it "deletes the object" do
      physical_object
      expect{ deletion }.to change(PhysicalObject, :count).by(-1)
    end
    it "redirects to the object index" do
      deletion
      expect(response).to redirect_to physical_objects_path
    end
  end
end
