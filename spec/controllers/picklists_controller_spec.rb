describe PicklistsController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:picklist) { FactoryGirl.create(:picklist, name: 'one') }
  let(:valid_picklist) { FactoryGirl.build(:picklist, name: 'two') }
  let(:invalid_picklist) { FactoryGirl.build(:invalid_picklist) }
  let(:physical_object) { FactoryGirl.create(:physical_object, :boxable, picklist: picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode ) }
  let(:box) { FactoryGirl.create(:box) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:blocked) { FactoryGirl.create(:physical_object, :boxable, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
  let(:condition) { FactoryGirl.create(:condition_status, condition_status_template_id: 1, active: true)}

  #no index

  describe "GET show regarding packing status" do
    before(:each) do
        blocked.picklist = picklist
        blocked.save!
        condition.physical_object = blocked
        condition.save!
      end
    context "physical objects with active blocking statuses" do
      before(:each) do
        get :show, id: picklist.id, format: :html
      end
      it "does assign blocked physical objects" do
        expect(assigns(:picklist).physical_objects).to include blocked
        expect(assigns(:blocked)).to eq [blocked]
      end
    end
    context "physical objects with inactive blocking statuses" do
      before(:each) do
        condition.active = false
        condition.save!
        get :show, id: picklist.id, format: :html
      end
      it "does not assign blocked physical objects" do
        expect(assigns(:picklist).physical_objects).to include blocked
        expect(assigns(:blocked)).to eq []
      end
    end
  end

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
      let(:show_csv) { get :show, id: "picklist_#{picklist.id}.csv", format: "csv" }
      it "sends a csv file" do
        expect(controller).to receive(:send_data).with(PhysicalObject.to_csv(picklist.physical_objects, picklist)) { controller.render nothing: true }
        show_csv
      end
    end
    context "xls format" do
      before(:each) { get :show, id: "picklist_#{picklist.id}.xls", format: "xls" }
      it "renders the :show template" do
        expect(response).to render_template(:show)
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
      it "saves the new picklist in the database" do
        expect{ creation }.to change(Picklist, :count).by(1)
      end
      it "redirects to the picklist specifications" do
        creation
        expect(response).to redirect_to(controller: :picklist_specifications, action: :index) 
      end
    end

    context "with invalid attributes" do
      let(:creation) { post :create, picklist: invalid_picklist.attributes.symbolize_keys }
      it "does not save the new picklist in the database" do
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
          expect{ pack_list }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "starting with empty pick list" do
        before(:each) do
          po1.picklist = nil
          po1.save!
          po2.picklist = nil
          po2.save!
          po3.picklist = nil
          po3.save!
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
          po1.save!
          po2.picklist = pack_picklist
          po2.save!
          po3.picklist = pack_picklist
          po3.save!
          if bin.nil? and box.nil?
            args[:bin_mdpi_barcode] = pack_bin
            args.delete :bin_id
            args.delete :box_id
            args.delete :physical_object
          end
        end
        it "finds nil/current/next physical objects" do
          pack_list
          expect(assigns(:previous_physical_object)).to eq po3
          expect(assigns(:wrap_previous)).to be true
          expect(assigns(:previous_packable_physical_object)).to eq po3
          expect(assigns(:wrap_previous_packable)).to be true

          expect(assigns(:physical_object)).to eq po1        
          expect(assigns(:tm)).to eq po1.technical_metadatum.specific
    
          expect(assigns(:next_physical_object)).to eq po2
          expect(assigns(:wrap_next)).to be_falsey
          expect(assigns(:next_packable_physical_object)).to eq po2
          expect(assigns(:wrap_next_packable)).to be_falsey
        end

        it "finds prev/current/next physical objects" do
          # for the test we don't need to differentiate on WHAT the physical object is pack in, only that it is packed
          po1.bin = pack_bin
          po1.save!
          pack_list
          
          expect(assigns(:previous_physical_object)).to eq po1
          expect(assigns(:wrap_previous)).to be_falsey
          expect(assigns(:previous_packable_physical_object)).to eq po3
          expect(assigns(:wrap_previous_packable)).to be true

          expect(assigns(:physical_object)).to eq po2
          expect(assigns(:tm)).to eq po2.technical_metadatum.specific

          expect(assigns(:next_physical_object)).to eq po3
          expect(assigns(:wrap_next)).to be_falsey
          expect(assigns(:next_packable_physical_object)).to eq po3
          expect(assigns(:wrap_next_packable)).to be_falsey
        end
        it "finds prev/current/nil physical objects" do
          po1.bin = pack_bin
          po1.save!
          po2.bin = pack_bin
          po2.save!
          pack_list
          expect(assigns(:previous_physical_object)).to eq po2
          expect(assigns(:wrap_previous)).to be_falsey
          expect(assigns(:previous_packable_physical_object)).to eq po3
          expect(assigns(:wrap_previous_packable)).to be true

          expect(assigns(:physical_object)).to eq po3        
          expect(assigns(:tm)).to eq po3.technical_metadatum.specific

          expect(assigns(:next_physical_object)).to eq po1
          expect(assigns(:wrap_next)).to be true
          expect(assigns(:next_packable_physical_object)).to eq po3
          expect(assigns(:wrap_next_packable)).to be true
        end
      end 

      context "starting with unpackable items on the pick list" do
        before(:each) do
          po1.picklist = pack_picklist
          po1.bin = pack_bin
          po1.save!
          po2.picklist = pack_picklist
          po2.bin = pack_bin
          po2.save!
          po3.picklist = pack_picklist
          po3.bin = pack_bin
          po3.save!
          if bin.nil? and box.nil?
            args[:bin_mdpi_barcode] = pack_bin
            args.delete :bin_id
            args.delete :box_id
            args.delete :physical_object
          end
        end
        it "doesn't find prev/current/next" do
          expect(assigns(:previous_physical_object)).to be_nil
          expect(assigns(:wrap_previous)).to be_falsey
          expect(assigns(:previous_packable_physical_object)).to be_nil
          expect(assigns(:wrap_previous_packable)).to be_falsey

          expect(assigns(:physical_object)).to be_nil
          expect(assigns(:tm)).to be_nil

          expect(assigns(:next_physical_object)).to be_nil
          expect(assigns(:wrap_next)).to be_falsey
          expect(assigns(:next_packable_physical_object)).to be_nil
          expect(assigns(:wrap_next_packable)).to be_falsey
        end
      end
    end
  end

  describe "PATCH pack_list on collection" do
    before(:each) { patch :pack_list, picklist: { id: picklist.id } }
    it "redirects to member" do
      expect(response).to redirect_to pack_list_picklist_path(picklist.id)
    end
  end

  describe "PATCH pack_list on member", "" do
    let(:pack_picklist) { FactoryGirl.create(:picklist, name: "Foo") }
    let(:pack_bin) { FactoryGirl.create(:bin, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, identifier: "binbar") }
    let(:pack_box) { FactoryGirl.create(:box, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode) }
    let(:pack_list) { patch :pack_list, args }
    let!(:po1) { FactoryGirl.create(:physical_object, :binnable, picklist: pack_picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, call_number: "A" ) }
    let!(:po2) { FactoryGirl.create(:physical_object, :binnable, picklist: pack_picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, call_number: "B" )}
    let!(:po3) { FactoryGirl.create(:physical_object, :binnable, picklist: pack_picklist, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode, call_number: "C" ) }
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

    context "submitting with invalid bin/box combinations" do
      shared_examples "does not pack" do
        before(:each) do
          args[:pack_button] = "Pack"
          args[:tm] = po2.technical_metadatum.specific.attributes
          args[:dp] = po2.digital_provenance.attributes
          pack_list
        end
        describe "pack button" do
          it "stays on the same object" do
	    expect(assigns(:physical_object)).to eq po2
	    expect(assigns(:tm)).to eq po2.technical_metadatum.specific
	  end
	  it "flashes a failure warning" do
	    expect(flash[:warning]).not_to be_blank
	  end
	  it "does not pack the object" do
	    po2.reload
	    expect(po2.bin).to be_nil
	    expect(po2.box).to be_nil
	  end
        end
      end
      context "with no bin or box specified" do
        let(:args) { {id: pack_picklist.id, physical_object: {id: po2.id}} }
	include_examples "does not pack"
      end
      context "with BOTH bin and box specified" do
        let(:args) { {id: pack_picklist.id, physical_object: {id: po2.id}, bin_mdpi_barcode: pack_bin.mdpi_barcode, box_mdpi_barcode: pack_box.mdpi_barcode } }
        include_examples "does not pack"
      end
    end

    context "submitting from picklist packing page with a Bin" do
      let(:args) { {id: pack_picklist.id, bin_id: pack_bin.id, physical_object: {id: po2.id}} }
      
      it "moves to previous object on previous button submission" do
        args[:previous_button] = "Previous"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po3
        expect(assigns(:wrap_previous)).to be true
        expect(assigns(:previous_packable_physical_object)).to eq po3
        expect(assigns(:wrap_previous_packable)).to be true

        expect(assigns(:physical_object)).to eq po1
        expect(assigns(:tm)).to eq po1.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po2
        expect(assigns(:wrap_next)).to be_falsey
        expect(assigns(:next_packable_physical_object)).to eq po2
        expect(assigns(:wrap_next_packable)).to be_falsey
      end
      it "moves to next object on next button submission" do
        args[:next_button] = "Previous"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes

        pack_list
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po2
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po1
        expect(assigns(:wrap_next)).to be true
        expect(assigns(:next_packable_physical_object)).to eq po1
        expect(assigns(:wrap_next_packable)).to be true
      end

      it "packs a physical object" do
        args[:pack_button] = "Pack"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po1
        expect(assigns(:wrap_next)).to be true
        expect(assigns(:next_packable_physical_object)).to eq po1
        expect(assigns(:wrap_next_packable)).to be true

        expect(po2.bin).to eq pack_bin
      end

      it "marks a picklist complete on last packed item" do
        po1.bin = pack_bin
        po1.save!
        po3.bin = pack_bin
        po3.save!
        args[:pack_button] = "Pack"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        pack_picklist.reload
        expect(pack_picklist.complete).to eq true
      end

      it "updates metadata fields on pack" do
        changed = "A new call number"
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        
        args[:physical_object][:call_number] = changed
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po1
        expect(assigns(:wrap_next)).to be true
        expect(assigns(:next_packable_physical_object)).to eq po1
        expect(assigns(:wrap_next_packable)).to be true

        expect(po2.bin).to eq pack_bin
        expect(po2.call_number).to eq changed
      end

      it "doesn't pack without an mdpi barcode" do
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        args[:physical_object][:mdpi_barcode] = '0'
        pack_list
        expect(assigns(:physical_object).errors[:mdpi_barcode]).to include("- Must assign a valid MDPI barcode to pack a Physical Object")
      end

      it "doesn't pack into a full bin" do
        pack_bin.current_workflow_status = "Sealed"
        pack_bin.save!
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        expect(flash[:warning]).to include("The current workflow status of Bin")
      end

      it "unpacks a physical object" do
        po2.bin = pack_bin
        po2.save!
        args[:unpack_button] = "Unpack"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.specific


        expect(assigns(:next_physical_object)).to eq po3
        expect(assigns(:wrap_next)).to be_falsey
        expect(assigns(:next_packable_physical_object)).to eq po3
        expect(assigns(:wrap_next_packable)).to be_falsey

        expect(po2.bin).to be_nil
        expect(po2.box).to be_nil
      end

      it "finds a physical object on a relevant search" do
        args[:search_button] = "Search"
        args[:call_number] = po2.call_number
        # args[:tm] = po2.technical_metadatum.specific.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po3
        expect(assigns(:wrap_next)).to be_falsey
        expect(assigns(:next_packable_physical_object)).to eq po3
        expect(assigns(:wrap_next_packable)).to be_falsey
      end

      describe "on an irrelevant search" do
        before(:each) do
          args[:search_button] = "Search"
          args[:call_number] = "Bad Call Number"
          pack_list
	end
	it "flashes a no item found warning" do
          expect(flash[:warning]).to match /no.*item.*found/i
	end
	it "loads the first item in the picklist" do
          expect(assigns(:previous_physical_object)).to eq po3
          expect(assigns(:wrap_previous)).to be true
          expect(assigns(:previous_packable_physical_object)).to eq po3
          expect(assigns(:wrap_previous)).to be true
  
          expect(assigns(:physical_object)).to eq po1
          expect(assigns(:tm)).to eq po1.technical_metadatum.specific

          expect(assigns(:next_physical_object)).to eq po2
          expect(assigns(:wrap_next)).to be_falsey
          expect(assigns(:next_packable_physical_object)).to eq po2
          expect(assigns(:wrap_next_packable)).to be_falsey
	end
      end
    end

    context "submitting from picklist packing page with no container specified" do
      let(:args) { {id: pack_picklist.id, bin_mdpi_barcode: pack_bin.mdpi_barcode, physical_object: {id: po2.id}} }
      
      it "moves to previous object on previous button submission" do
        args[:previous_button] = "Previous"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po3
        expect(assigns(:wrap_previous)).to be true
        expect(assigns(:previous_packable_physical_object)).to eq po3
        expect(assigns(:wrap_previous_packable)).to be true

        expect(assigns(:physical_object)).to eq po1
        expect(assigns(:tm)).to eq po1.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po2
        expect(assigns(:wrap_next)).to be_falsey
        expect(assigns(:next_packable_physical_object)).to eq po2
        expect(assigns(:wrap_next_packable)).to be_falsey
      end
      it "moves to next object on next button submission" do
        args[:next_button] = "Previous"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po2
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po1
        expect(assigns(:wrap_next)).to be true
        expect(assigns(:next_packable_physical_object)).to eq po1
        expect(assigns(:wrap_next_packable)).to be true
      end
      it "packs a physical object" do
        args[:pack_button] = "Pack"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po1
        expect(assigns(:wrap_next)).to be true
        expect(assigns(:next_packable_physical_object)).to eq po1
        expect(assigns(:wrap_next_packable)).to be true

        expect(po2.bin).to eq pack_bin
        expect(pack_picklist.complete).to eq false
      end
      it "updates metadata fields on pack" do
        changed = "A new call number"
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        args[:physical_object][:call_number] = changed
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po2
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po3
        expect(assigns(:tm)).to eq po3.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po1
        expect(assigns(:wrap_next)).to be true
        expect(assigns(:next_packable_physical_object)).to eq po1
        expect(assigns(:wrap_next_packable)).to be true

        expect(po2.bin).to eq pack_bin
        expect(po2.call_number).to eq changed
      end
      it "doesn't pack without an mdpi barcode" do
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        args[:physical_object][:mdpi_barcode] = '0'
        pack_list
        expect(assigns(:physical_object).errors[:mdpi_barcode]).to include("- Must assign a valid MDPI barcode to pack a Physical Object")
      end
      it "doesn't pack into a full bin" do
        pack_bin.current_workflow_status = "Sealed"
        pack_bin.save!
        args[:pack_button] = "Pack"
        args[:physical_object] = po2.attributes
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        expect(flash[:warning]).to include("The current workflow status of Bin")
      end
      it "unpacks a physical object" do
        po2.bin = pack_bin
        po2.save!
        args[:unpack_button] = "Unpack"
        args[:tm] = po2.technical_metadatum.specific.attributes
        args[:dp] = po2.digital_provenance.attributes
        pack_list
        po2.reload
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po3
        expect(assigns(:wrap_next)).to be_falsey
        expect(assigns(:next_packable_physical_object)).to eq po3
        expect(assigns(:wrap_next_packable)).to be_falsey

        expect(po2.bin).to be_nil
        expect(po2.box).to be_nil
      end
      it "finds a physical object on a relevant search" do
        args[:search_button] = "Search"
        args[:call_number] = po2.call_number
        # args[:tm] = po2.technical_metadatum.specific.attributes
        pack_list
        expect(assigns(:previous_physical_object)).to eq po1
        expect(assigns(:wrap_previous)).to be_falsey
        expect(assigns(:previous_packable_physical_object)).to eq po1
        expect(assigns(:wrap_previous_packable)).to be_falsey

        expect(assigns(:physical_object)).to eq po2
        expect(assigns(:tm)).to eq po2.technical_metadatum.specific

        expect(assigns(:next_physical_object)).to eq po3
        expect(assigns(:wrap_next)).to be_falsey
        expect(assigns(:next_packable_physical_object)).to eq po3
        expect(assigns(:wrap_next_packable)).to be_falsey

      end
      describe "on an irrelevant search" do
        before(:each) do
          args[:search_button] = "Search"
          args[:call_number] = "Bad Call Number"
          pack_list
        end
        it "flashes a no item found warning" do
          expect(flash[:warning]).to match /no.*item.*found/i
        end
        it "loads the first item in the picklist" do
          expect(assigns(:previous_physical_object)).to eq po3
          expect(assigns(:wrap_previous)).to be true
          expect(assigns(:previous_packable_physical_object)).to eq po3
          expect(assigns(:wrap_previous)).to be true

          expect(assigns(:physical_object)).to eq po1
          expect(assigns(:tm)).to eq po1.technical_metadatum.specific

          expect(assigns(:next_physical_object)).to eq po2
          expect(assigns(:wrap_next)).to be_falsey
          expect(assigns(:next_packable_physical_object)).to eq po2
          expect(assigns(:wrap_next_packable)).to be_falsey
        end
      end
    end

    # context "pack_list picklist completion" do
    #   let(:args) { {id: pack_picklist.id, bin_id: pack_bin.id, physical_object: {id: po3.id}, tm: po3.technical_metadatum.specific.attributes, pack_button: 'Pack' }}
    #   before(:each) do
    #     po1.picklist = pack_picklist
    #     po1.bin = pack_bin
    #     po1.save!
    #     po2.picklist = pack_picklist
    #     po2.bin = pack_bin
    #     po2.save!
    #     po3.picklist = pack_picklist
    #     po3.save!
    #     patch :pack_list, args
    #   end
    #   it "packs last item and completes picklist" do
    #     expect(assigns(:picklist)).to eq pack_picklist
    #     expect(assigns(:picklist).complete).to eq true
    #   end
    # end
  end

end
