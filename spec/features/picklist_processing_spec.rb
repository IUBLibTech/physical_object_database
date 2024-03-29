feature "Picklist Processing", js: true do

  pending "Rewrite tests using new pick list processing functionality" do 
    let(:picklist) { FactoryBot.create :picklist }
    let(:bin) { FactoryBot.create :bin }
    let(:physical_object) { FactoryBot.create :physical_object, :cdr, picklist: picklist, bin: bin, mdpi_barcode: BarcodeHelper.valid_mdpi_barcode }

    before(:each) do
      sign_in
      picklist
      bin
      physical_object
    end
    context "on processing screen" do
      scenario "should load without errors", js: true do
        visit process_list_picklists_path( picklist: { id: picklist.id} )
        conclude_jquery
      end
      scenario "object is removed after popup confirmation" do
        visit process_list_picklists_path( picklist: { id: picklist.id} ) 
        confirm_popup
        click_link 'Remove'
        conclude_jquery
        physical_object.reload
        expect(physical_object.picklist).to be_nil
      end
      scenario "object is NOT removed after popup rejection" do
        visit process_list_picklists_path( picklist: { id: picklist.id} ) 
        expect(physical_object.picklist).not_to be_nil
        reject_popup { click_link 'Remove' }
        #click_link 'Remove'
        #reject_popup
        #conclude_jquery
        physical_object.reload
        expect(physical_object.picklist).not_to be_nil
      end
      scenario "packs object when Pack is clicked" do
        physical_object.bin = nil
        physical_object.save
        visit process_list_picklists_path( picklist: { id: picklist.id} ) 
        fill_in 'bin_barcode', with: bin.mdpi_barcode
        click_button 'Pack'
        conclude_jquery
        physical_object.reload
        expect(physical_object.bin).not_to be_nil
      end
      scenario "unpacks object when Unpack is clicked" do
        visit process_list_picklists_path( picklist: { id: picklist.id} )
        click_button 'Unpack'
        conclude_jquery
        physical_object.reload
        expect(physical_object.bin).to be_nil
        expect(physical_object.box).to be_nil
      end
      scenario "can Remove object after Unpacking" do
        visit process_list_picklists_path( picklist: { id: picklist.id} )
        click_button 'Unpack'
        skip "Remove link is broken after Pack/Unpack action: POD-362"
        click_link 'Remove'
        confirm_popup
        physical_object.reload
        expect(physical_object.picklist).to be_nil
      end
    end
  end

end
