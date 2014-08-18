require 'rails_helper'

describe PicklistsController do
  before(:each) { sign_in }
  let(:picklist) { FactoryGirl.create(:picklist) }

  describe "GET show" do
    context "html format" do
      before(:each) { get :show, id: picklist.id, format: :html }
      it "assigns the requested picklist to @picklist" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
    end
    context "csv format" do
      let(:show_csv) { get :show, id: picklist.id, format: :csv }
      it "assigns the requested picklist to @picklist" do
        show_csv
        expect(assigns(:picklist)).to eq picklist
      end
      it "sends a csv file" do
        expect(controller).to receive(:send_data).with(PhysicalObject.to_csv(picklist.physical_objects, picklist)) { controller.render nothing: true }
	show_csv
      end
      #TODO: test file content
    end
    context "xls format" do
      let(:show_xls) { get :show, id: picklist.id, format: :xls }
      it "assigns the requested picklist to @picklist" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "renders the :show template" do
        #expect(response).to render_template(:show)
      end
      #TODO: test file content
    end
  end
end
