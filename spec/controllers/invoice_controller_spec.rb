require 'rails_helper'

RSpec.describe InvoiceController, type: :controller do
	render_views
	let!(:po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000102782) }
	
	before(:each) { 
		sign_in 
		@file = fixture_file_upload("partial_memnon_test.xlsx")
	}

	it "sets physical objects to billed" do
		post :submit, xls_file: @file
		po.reload
		expect(po.billed).to eq true
	end

	it "does not re-bill a physical object" do
		post :submit, xls_file: @file
		post :submit, xls_file: @file
		expect(response).to render_template(:failed)
	end

end
