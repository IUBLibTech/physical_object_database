require 'rails_helper'

describe SpreadsheetsController do
  render_views
  before(:each) { sign_in }
  let(:spreadsheet) { FactoryGirl.create :spreadsheet }
  let(:valid_spreadsheet) { FactoryGirl.build :spreadsheet }
  let(:invalid_spreadsheet) { FactoryGirl.build :invalid_spreadsheet }

  describe "GET index" do
    before(:each) do
      spreadsheet.save
      get :index
    end
    it "assigns all spreadsheets as @spreadsheets" do
      expect(assigns(:spreadsheets)).to eq [spreadsheet] 
    end
    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: spreadsheet.id }
    it "assigns the requested spreadsheet as @spreadsheet" do
      expect(assigns(:spreadsheet)).to eq spreadsheet 
    end
    it "assigns associated bins objects as @bins" do
      expect(assigns(:bins)).to eq []
    end
    it "assigns associated physical objects as @boxes" do
      expect(assigns(:boxes)).to eq []
    end
    it "assigns associated physical objects as @physical_objects" do
      expect(assigns(:physical_objects)).to eq []
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
    it "provides XLS export" do
      skip "XLS rendering broken?"
    end
  end

  #new disabled

  describe "GET edit" do
    before(:each) { get :edit, id: spreadsheet.id }
    it "assigns the requested spreadsheet as @spreadsheet" do
      expect(assigns(:spreadsheet)).to eq spreadsheet 
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  #create disabled

  describe "PUT update" do
    context "with valid params" do
      before(:each) do
        put :update, id: spreadsheet.id, spreadsheet: FactoryGirl.attributes_for(:spreadsheet, filename: "Updated filename")
      end

      it "updates the requested spreadsheet" do
        expect(spreadsheet.filename).not_to eq "Updated filename"
        spreadsheet.reload
	expect(spreadsheet.filename).to eq "Updated filename"
      end

      it "assigns the requested spreadsheet as @spreadsheet" do
        expect(assigns(:spreadsheet)).to eq spreadsheet 
      end

      it "redirects to the spreadsheet" do
        expect(response).to redirect_to(spreadsheet)
      end
    end

    describe "with invalid params" do
      before(:each) do
        put :update, id: spreadsheet.id, spreadsheet: FactoryGirl.attributes_for(:invalid_spreadsheet)
      end
      it "assigns the spreadsheet as @spreadsheet" do
        expect(assigns(:spreadsheet)).to eq spreadsheet 
      end

      it "does not change the object's attributes" do
        original_filename = spreadsheet.filename
	spreadsheet.reload
	expect(spreadsheet.filename).to eq original_filename
      end

      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    let(:deletion) { delete :destroy, id: spreadsheet.id }
    context "with no updated objects" do
      it "destroys the requested spreadsheet" do
        spreadsheet
        expect{ deletion }.to change(Spreadsheet, :count).by(-1)
      end
      it "redirects to the spreadsheets list" do
        deletion
        expect(response).to redirect_to spreadsheets_url 
      end
    end
    context "with updated objects" do
      let(:physical_object) { FactoryGirl.create :physical_object, :cdr, spreadsheet: spreadsheet }
      before(:each) do
        physical_object.updated_at = Time.now() + 10
        physical_object.save
      end
      context "without confirmation" do
        it "does not delete the spreadsheet" do
	  expect{ deletion }.not_to change(Spreadsheet, :count)
	end
        it "renders the deletion confirmation page" do
          deletion
	  expect(response).to render_template "confirm_delete"
        end
      end
      context "with confirmation" do
        let(:confirmed_deletion) { delete :destroy, id: spreadsheet.id, confirmed: "true" }
        it "destroys the requested spreadsheet" do
          spreadsheet
          expect{ confirmed_deletion }.to change(Spreadsheet, :count).by(-1)
	end
	it "redirects to the spreadsheets list" do
	  confirmed_deletion
          expect(response).to redirect_to spreadsheets_url
	end
      end
    end
  end

end
