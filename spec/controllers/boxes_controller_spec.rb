#FIXME: rewrite for boxes!
require 'rails_helper'

describe BoxesController do
  render_views
  before(:each) { sign_in }
  let(:batch) { FactoryGirl.create(:batch) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:other_bin) { FactoryGirl.create(:bin, identifier: "other " + bin.identifier) }
  let(:box) { FactoryGirl.create(:box) }
  let(:binned_box) { FactoryGirl.create(:box, bin: bin) }
  let(:boxed_object) { FactoryGirl.create(:physical_object, :cdr, box: box) }
  let(:binned_object) { FactoryGirl.create(:physical_object, :cdr, bin: bin) }
  let(:picklist) { FactoryGirl.create(:picklist) }
  let(:spreadsheet) { FactoryGirl.create(:spreadsheet) }
  let(:valid_box) { FactoryGirl.build(:box) }
  let(:invalid_box) { FactoryGirl.build(:invalid_box) }

  describe "FactoryGirl creation" do
    specify "makes a valid box" do
      expect(valid_box).to be_valid
    end
    specify "makes an invalid bin" do
      expect(invalid_box).to be_invalid
    end
  end

  describe "GET index" do
    context "specifying a bin" do
      before(:each) do
        bin.save
        binned_box.save
        box.save
        get :index, bin_id: bin.id
      end
      it "assigns @bin" do
        expect(assigns(:bin)).to eq bin
      end
      it "populates boxes in that bin" do
        expect(assigns(:boxes)).to eq [binned_box]
      end
      it "renders the :index view" do
        expect(response).to render_template(:index)
      end
    end
    context "without specifying a bin" do
      before(:each) do
        binned_box.save
        box.save
        get :index
      end
      it "populates unbinned boxes" do
        expect(assigns(:boxes)).to eq [box]
      end
      it "renders the :index view" do
        expect(response).to render_template(:index)
      end
    end
  end

  describe "GET show" do
    before(:each) do
      picklist
      boxed_object
      box
      get :show, id: box.id
    end
    it "assigns the requested object to @box" do
      expect(assigns(:box)).to eq box
    end
    it "assigns boxed @physical_objects" do
      expect(assigns(:physical_objects)).to eq [boxed_object]
    end
    include_examples "provides pagination", :physical_objects
    it "builds @picklist select array" do
      expect(assigns(:picklists)).to eq [[picklist.name,picklist.id]]
    end
    it "renders the :show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET new" do
    context "specifying a bin" do
      before(:each) { get :new, bin_id: bin.id }
      it "assigns @bin" do
        expect(assigns(:bin)).to eq bin
      end
      it "creates a box associated to the bin" do
        expect(assigns(:box).bin).to eq bin
      end
      it "renders the :new template" do
        expect(response).to render_template :new
      end
    end
    context "not specifying a bin" do
      before(:each) { get :new }
      it "creates a box with no bin association" do
        expect(assigns(:box)).to be_a_new Box
      end
      it "renders the :new template" do
        expect(response).to render_template :new
      end
    end
  end

  #edit disabled

  describe "POST create" do
    context "with valid attributes" do
      let(:creation) { post :create, box: valid_box.attributes.symbolize_keys }
      it "saves the new object in the database" do
        expect{ creation }.to change(Box, :count).by(1)
      end
      it "redirects to the object" do
        creation
        expect(response).to redirect_to assigns(:box)
      end
    end
    context "with invalid attributes" do
      let(:creation) { post :create, box: invalid_box.attributes.symbolize_keys }
      it "does not save the new object in the database" do
        expect{ creation }.not_to change(Box, :count)
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
        put :update, id: box.id, box: FactoryGirl.attributes_for(:box, spreadsheet_id: spreadsheet.id)
      end
      it "locates the requested object" do
        expect(assigns(:box)).to eq box
      end
      it "changes the object's attributes" do
        expect(box.spreadsheet).to be_nil
        box.reload
        expect(box.spreadsheet).to eq spreadsheet
      end
      it "redirects to the updated object" do
        expect(response).to redirect_to(action: :show) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: box.id, box: FactoryGirl.attributes_for(:invalid_box)
      end
      it "locates the requested object" do
        expect(assigns(:box)).to eq box
      end
      it "does not change the object's attributes"
      it "redirects to the object" do
        expect(response).to redirect_to action: :show
      end
    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: box.id }
    it "deletes the object" do
      box
      expect{ deletion }.to change(Box, :count).by(-1)
    end
    it "redirects to the bins index" do
      deletion
      expect(response).to redirect_to bins_path
    end
    it "disassociates remaining physical objects" do
      boxed_object
      deletion
      boxed_object.reload
      expect(boxed_object.box).to be_nil
    end
  end

  describe "PUT unbin" do
    context "specifying a bin" do
      context "when binned" do
        before(:each) { put :unbin, id: binned_box.id, bin_id: bin.id }
        it "unbins the box" do
          binned_box.reload
          expect(binned_box.bin).to be_nil
        end
        it "flashes a success notice" do
          expect(flash[:notice]).to match /Success/
        end
        it "redirects to the bin" do
          expect(response).to redirect_to bin
        end
      end
      context "when binned, but in a different bin" do
        before(:each) { put :unbin, id: binned_box, bin_id: other_bin.id }
	it "flashes a different association notice" do
	  expect(flash[:notice]).to match /different/
	end
	it "redirects to the bin" do
	  expect(response).to redirect_to other_bin
	end
      end
      context "when not in a bin" do
        before(:each) { put :unbin, id: box.id, bin_id: bin.id }
        it "flashes a not associated notice" do
          expect(flash[:notice]).to match /not associated/
        end
        it "redirects to the bin" do
          expect(response).to redirect_to bin
        end
      end
    end
    context "not specifying a bin" do
      context "when binned" do
        before(:each) { put :unbin, id: binned_box.id }
        it "unbins the box" do
          binned_box.reload
          expect(binned_box.bin).to be_nil
        end
        it "flashes a success notice" do
          expect(flash[:notice]).to match /Success/
        end
        it "redirects to the box" do
          expect(response).to redirect_to binned_box
        end
      end
      context "when not in a bin" do
        before(:each) { put :unbin, id: box.id }
        it "flashes a not associated notice" do
          expect(flash[:notice]).to match /not associated/
        end
        it "redirects to the box" do
          expect(response).to redirect_to box
        end
      end
    end
  end

  describe "PUT add_barcode_item" do
    it "FIXME: deprecated?"
  end
  
end
