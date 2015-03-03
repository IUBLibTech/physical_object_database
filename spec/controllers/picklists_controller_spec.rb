require 'rails_helper'

describe PicklistsController do
  render_views
  before(:each) { sign_in }
  let(:picklist) { FactoryGirl.create(:picklist) }
  let(:valid_picklist) { FactoryGirl.build(:picklist) }
  let(:invalid_picklist) { FactoryGirl.build(:invalid_picklist) }
  let(:physical_object) { FactoryGirl.create(:physical_object, :cdr, picklist: picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode ) }
  let(:box) { FactoryGirl.create(:box) }
  let(:bin) { FactoryGirl.create(:bin) }

  #no index

  describe "GET show on member" do
    context "html format" do
      before(:each) { get :show, id: picklist.id, format: :html }
      it "assigns the requested picklist to @picklist" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
      include_examples "provides pagination", :physical_objects
    end
    context "csv format" do
      let(:show_csv) { get :show, id: picklist.id, format: :csv }
      it "sends a csv file" do
        expect(controller).to receive(:send_data).with(PhysicalObject.to_csv(picklist.physical_objects, picklist)) { controller.render nothing: true }
        show_csv
      end
      include_examples "does not provide pagination", :physical_objects
    end
    context "xls format" do
      let(:show_xls) { get :show, id: picklist.id, format: :xls }
      it "renders the :show template" do
        skip "test should pass for Excel template, but fails"
        #expect(response).to render_template(:show)
      end
      it "contains the correct Excel file content" do
        skip "TODO: test Excel file content"
      end
      include_examples "does not provide pagination", :physical_objects
    end
  end

  describe "GET new on collection" do
    before(:each) { get :new }
    it "assigns a new object to @picklist" do
      expect(assigns(:picklist)).to be_a_new(Picklist)
    end
    it "renders the :new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET edit on member" do
    before(:each) { get :edit, id: picklist.id }
    it "locates the requested object" do
      expect(assigns(:picklist)).to eq picklist
    end
    it "renders the :edit template" do
      expect(response).to render_template(:edit) 
    end
  end

  describe "POST create on member" do
    context "with valid attributes" do
      let(:creation) { post :create, picklist: valid_picklist.attributes.symbolize_keys }
      it "saves the new physical object in the database" do
        expect{ creation }.to change(Picklist, :count).by(1)
      end
      it "redirects to the picklist specifications" do
        creation
        expect(response).to redirect_to(controller: :picklist_specifications, action: :index) 
      end
    end

    context "with invalid attributes" do
      let(:creation) { post :create, picklist: invalid_picklist.attributes.symbolize_keys, tm: FactoryGirl.attributes_for(:cdr_tm) }
      it "does not save the new physical object in the database" do
        expect(invalid_picklist).to be_invalid
        expect{ creation }.not_to change(Picklist, :count)
      end
      it "re-renders the :new template" do
        creation
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT update on member" do
    context "with valid attributes" do
      before(:each) do
        put :update, id: picklist.id, picklist: FactoryGirl.attributes_for(:picklist, name: "Updated Test Picklist", complete: true)
      end

      it "locates the requested object" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "changes the object's attributes" do
        expect(picklist.name).not_to eq "Updated Test Picklist"
        picklist.reload
        expect(picklist.name).to eq "Updated Test Picklist"
        expect(picklist.complete).to eq true
      end
      it "redirects to the picklist specficications index" do
        expect(response).to redirect_to(controller: :picklist_specifications, action: :index) 
      end
    end
    context "with invalid attributes" do
      before(:each) do
        put :update, id: picklist.id, picklist: FactoryGirl.attributes_for(:invalid_picklist)
      end

      it "locates the requested object" do
        expect(assigns(:picklist)).to eq picklist
      end
      it "does not change the object's attributes" do
        expect(picklist.description).not_to eq "Invalid picklist description"
        picklist.reload
        expect(picklist.description).not_to eq "Invalid picklist description"
      end
      it "re-renders the :edit template" do
        expect(response).to render_template(:edit)
      end

    end
  end

  describe "DELETE destroy on member" do
    let(:deletion) { delete :destroy, id: picklist.id }
    it "deletes the object" do
      picklist
      expect{ deletion }.to change(Picklist, :count).by(-1)
    end
    it "redirects to the picklist specifications index" do
      deletion
      expect(response).to redirect_to picklist_specifications_path
    end
    it "disassociates physical objects" do
      expect(physical_object.picklist_id).not_to be_nil
      deletion
      physical_object.reload
      expect(physical_object.picklist_id).to be_nil
    end
  end

  shared_examples_for "starting a picklist packing session" do 
    before(:each) do
      request.env['HTTP_REFERER'] = "Foo"
    end

    context "while packing a picklist" do  
      context " starting with missing pick list param" do
        before(:each) do
          args.delete :id
          pack_list
        end
        it "redirects to pick list specifications page" do
          expect(response).to redirect_to picklist_specifications_path 
        end
      end

      context "starting with invalid pick list id" do
        before(:each) {
          args[:id] = -1
        }
        it "raises error" do
          expect{ pack_list }.to raise_error
        end
      end

      context "starting with empty pick list" do
        before(:each) do
          po1.picklist = nil
          po1.save
          po2.picklist = nil
          po2.save
          po3.picklist = nil
          po3.save
          pack_list
        end
        it "finds the pick list" do
          expect(assigns(:picklist)).to eq pack_picklist
        end
        
        it "cannot find a physical object" do
          expect(assigns(:physical_object)).to be_nil
        end
      end

      context " starting with packable items on pick list" do
        before(:each) do
          po1.picklist = pack_picklist
          po1.save
          po2.picklist = pack_picklist
          po2.save
          po3.picklist = pack_picklist
          po3.save
          if bin.nil? and box.nil?
            args[:bin_mdpi_barcode] = pack_bin
            args.delete :bin_id
            args.delete :box_id
            args.delete :physical_object
          end
        end
        it "finds nil/current/next physical objects" do
          pack_list
          expect(assigns(:previous_physical_object)).to be_nil
          expect(assigns(:physical_object)).to eq po1        
          expect(assigns(:tm)).to eq po1.technical_metadatum.as_technical_metadatum        
          expect(assigns(:next_physical_object)).to eq po2
        end

        it "finds prev/current/next physical objects" do
          # for the test we don't need to differentiate on WHAT the physical object is pack in, only that it is packed
          po1.bin = pack_bin
          po1.save
          pack_list
          
          expect(assigns(:previous_physical_object)).to eq po1
          expect(assigns(:physical_object)).to eq po2
          expect(assigns(:tm)).to eq po2.technical_metadatum.as_technical_metadatum
          expect(assigns(:next_physical_object)).to eq po3
        end
        it "finds prev/current/nil physical objects" do
          po1.bin = pack_bin
          po1.save
          po2.bin = pack_bin
          po2.save
          pack_list
          expect(assigns(:previous_physical_object)).to eq po2
          expect(assigns(:physical_object)).to eq po3        
          expect(assigns(:tm)).to eq po3.technical_metadatum.as_technical_metadatum
          expect(assigns(:next_physical_object)).to be_nil
        end
      end 

      context "starting with unpackable items on the pick list" do
        before(:each) do
          po1.picklist = pack_picklist
          po1.bin = pack_bin
          po1.save
          po2.picklist = pack_picklist
          po2.bin = pack_bin
          po2.save
          po3.picklist = pack_picklist
          po3.bin = pack_bin
          po3.save
          if bin.nil? and box.nil?
            args[:bin_mdpi_barcode] = pack_bin
            args.delete :bin_id
            args.delete :box_id
            args.delete :physical_object
          end
        end
        it "doesn't find prev/current/next" do
          expect(assigns(:previous_physical_object)).to be_nil
          expect(assigns(:physical_object)).to be_nil
          expect(assigns(:next_physical_object)).to be_nil
        end
      end
    end
  end

  describe "PATCH pack_list on collection" do
    skip "redirects to member"
  end

  describe "PATCH pack_list on member", "" do
    let(:pack_picklist) { FactoryGirl.create(:picklist, name: "Foo") }
    let(:pack_bin) { FactoryGirl.create(:bin, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, identifier: "binbar") }
    let(:pack_box) { FactoryGirl.create(:box, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
    let(:pack_list) { patch :pack_list, args }
    let!(:po1) { FactoryGirl.create(:physical_object, :cdr, picklist: pack_picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, call_number: "A" ) }
    let!(:po2) { FactoryGirl.create(:physical_object, :cdr, picklist: pack_picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, call_number: "B" )}
    let!(:po3) { FactoryGirl.create(:physical_object, :cdr, picklist: pack_picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, call_number: "C" ) }
    let(:tm) {}

    pack_mode = "auto-box"
    it_behaves_like "starting a picklist packing session" do 
      let(:args) { {id: pack_picklist.id, box_id: pack_box.id } }
    end

    pack_mode = "auto-bin"
    it_behaves_like "starting a picklist packing session" do
      let(:args) { {id: pack_picklist.id, bin_id: pack_bin.id}}
    end

    pack_mode = "manually (with bin barcode)"
    it_behaves_like "starting a picklist packing session" do
      let(:args) { {id: pack_picklist.id, bin_mdpi_barcode: pack_bin.mdpi_barcode} }
    end

    pack_mode = "manually (with box barcode)"
    it_behaves_like "starting a picklist packing session" do
      let(:args) { {id: pack_picklist.id, box_mdpi_barcode: pack_box.mdpi_barcode} }
    end

    context "submitting from picklist packing page with a Bin" do
      let(:args) { {id: pack_picklist.id, bin_id: pack_bin.id, physical_object: {id: po2.id}} }
      
      before(:each) do
        request.env['HTTP_REFERER'] = "Foo"
      end
      it "moves to previous object on previous button submission" do
        args[:previous_button] = "Previous"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to be_nil
        expect(assigns(:physical_object)).to eq po1
        expect(assigns(:tm)).to eq po1.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to eq po2
      end
      it "moves to next object on next button submission" do
        args[:next_button] = "Previous"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to be_nil
      end

      it "packs a physical object" do
        args[:pack_button] = "Pack"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to be_nil
        expect(po2.bin).to eq pack_bin
      end

      it "updates metadata fields on pack" do
        changed = "A new call number"
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        
        args[:physical_object][:call_number] = changed
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to be_nil
        expect(po2.bin).to eq pack_bin
        expect(po2.call_number).to eq changed
      end

      it "doesn't pack without an mdpi barcode" do
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        args[:physical_object][:mdpi_barcode] = '0'
        pack_list
        expect(assigns(:physical_object).errors[:mdpi_barcode]).to include("- Must assign a valid MDPI barcode to pack a Physical Object")
      end

      it "doesn't pack into a full bin" do
        pack_bin.current_workflow_status = "Sealed"
        pack_bin.save
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(flash[:warning]).to include("The current workflow status of Bin")
      end

      it "unpacks a physical object" do
        po2.bin = pack_bin
        po2.save
        args[:unpack_button] = "Unpack"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to eq po3
        expect(po2.bin).to be_nil
        expect(po2.box).to be_nil
      end

      it "finds a physical object on a relevant search" do
        args[:search_button] = "Search"
        args[:call_number] = po2.call_number
        # args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to eq po3
      end

      it "doesn't find a physical object on an irrelevant search" do
        args[:search_button] = "Search"
        args[:call_number] = "Bad Call Number"
        # args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to be_nil
        expect(assigns(:physical_object)).to be_nil
        expect(assigns(:next_physical_object)).to be_nil
      end
    end

    context "submitting from picklist packing page with no container specified" do
      let(:args) { {id: pack_picklist.id, bin_mdpi_barcode: pack_bin.mdpi_barcode, physical_object: {id: po2.id}} }
      
      before(:each) do
        request.env['HTTP_REFERER'] = "Foo"
      end

      it "moves to previous object on previous button submission" do
        args[:previous_button] = "Previous"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to be_nil
        expect(assigns(:physical_object)).to eq po1
        expect(assigns(:tm)).to eq po1.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to eq po2
      end
      it "moves to next object on next button submission" do
        args[:next_button] = "Previous"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to be_nil
      end
      it "packs a physical object" do
        args[:pack_button] = "Pack"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to be_nil
        expect(po2.bin).to eq pack_bin
      end
      it "updates metadata fields on pack" do
        changed = "A new call number"
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        args[:physical_object][:call_number] = changed
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to be_nil
        expect(po2.bin).to eq pack_bin
        expect(po2.call_number).to eq changed
      end
      it "doesn't pack without an mdpi barcode" do
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        args[:physical_object][:mdpi_barcode] = '0'
        pack_list
        expect(assigns(:physical_object).errors[:mdpi_barcode]).to include("- Must assign a valid MDPI barcode to pack a Physical Object")
      end
      it "doesn't pack into a full bin" do
        pack_bin.current_workflow_status = "Sealed"
        pack_bin.save
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(flash[:warning]).to include("The current workflow status of Bin")
      end
      it "unpacks a physical object" do
        po2.bin = pack_bin
        po2.save
        args[:unpack_button] = "Unpack"
        args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to eq po3
        expect(po2.bin).to be_nil
        expect(po2.box).to be_nil
      end
      it "finds a physical object on a relevant search" do
        args[:search_button] = "Search"
        args[:call_number] = po2.call_number
        # args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.as_technical_metadatum
        expect(assigns(:next_physical_object)).to eq po3
      end
      it "doesn't find a physical object on an irrelevant search" do
        args[:search_button] = "Search"
        args[:call_number] = "Bad Call Number"
        # args[:tm] = po2.technical_metadatum.as_technical_metadatum.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to be_nil
        expect(assigns(:physical_object)).to be_nil
        expect(assigns(:next_physical_object)).to be_nil
      end

    end
  end

end
