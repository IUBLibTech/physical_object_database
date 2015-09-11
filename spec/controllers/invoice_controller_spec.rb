require 'rails_helper'

RSpec.describe InvoiceController, type: :controller do
	render_views


	let!(:good_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000070013, digital_start: Time.now) }
	let!(:not_sda_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000070021, digital_start: nil) }
	let!(:billed_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000102782, digital_start: Time.now, billed: true, spread_sheet_filename: "Some Other Spreadhsheet") }

	before(:each) { 
		sign_in 
	}


	it "validates a good invoice" do
		good_po.reload
		expect(good_po.billed).to be false
		@good = fixture_file_upload("Memnon Good.xlsx")
		InvoiceHelper.process(@good)
		mis = MemnonInvoiceSubmission.last
		expect(mis.filename).to eq "Memnon Good.xlsx"
		expect(mis.successful_validation).to eq true
		good_po.reload
		expect(good_po.billed).to eq true
		expect(good_po.spread_sheet_filename).to eq "Memnon Good.xlsx"
	end

	it "fails an invoice with missing barcode" do
		@missing = fixture_file_upload("Memnon Missing Barcode.xlsx")
		InvoiceHelper.process(@missing)
		mis = MemnonInvoiceSubmission.last
		expect(mis.filename).to eq "Memnon Missing Barcode.xlsx"
		expect(mis.not_found.size).to eq 1
		expect(mis.successful_validation).to eq false
	end

	it "fails an invoice with barcodes not yet on SDA" do
		@sda = fixture_file_upload("Memnon Not on SDA.xlsx")
		InvoiceHelper.process(@sda)
		mis = MemnonInvoiceSubmission.last
		expect(mis.filename).to eq "Memnon Not on SDA.xlsx"
		expect(mis.not_on_sda.size).to eq 1
		expect(mis.successful_validation).to eq false
	end

	it "fails an invoice that contains an already billed physical object" do
		@already = fixture_file_upload("Memnon Already Billed.xlsx")
		InvoiceHelper.process(@already)
		mis = MemnonInvoiceSubmission.last
		expect(mis.filename).to eq "Memnon Already Billed.xlsx"
		expect(mis.already_billed.size).to eq 1
		expect(mis.successful_validation).to eq false
		billed_po.reload
		expect(billed_po.spread_sheet_filename).to_not eq "Memnon Already Billed.xlsx"
	end

	it "fails with duplicate preservation master filenames" do
		@dup = fixture_file_upload("Memnon Duplicate Pres File.xlsx")
		InvoiceHelper.process(@dup)
		mis = MemnonInvoiceSubmission.last
		expect(mis.filename).to eq "Memnon Duplicate Pres File.xlsx"
		expect(mis.preservation_file_copies.size).to eq 1
		expect(mis.successful_validation).to eq false
	end


end
