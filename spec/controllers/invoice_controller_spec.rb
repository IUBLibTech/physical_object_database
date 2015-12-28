describe InvoiceController do
	render_views
	before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

	let!(:good_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000070013, digital_start: Time.now) }
	let!(:not_sda_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000070021, digital_start: nil) }
	let!(:billed_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000102782, digital_start: Time.now, billed: true, spread_sheet_filename: "Some Other Spreadhsheet") }

	it "validates a good invoice" do
		good_po.reload
		expect(good_po.billed).to be false
		@good = fixture_file_upload("Memnon Good.xlsx")
		InvoiceHelper.process_rows(@good)
		mis = MemnonInvoiceSubmission.last
		expect(mis.filename).to eq "Memnon Good.xlsx"
		expect(mis.successful_validation).to eq true
		good_po.reload
		expect(good_po.billed).to eq true
		expect(good_po.spread_sheet_filename).to eq "Memnon Good.xlsx"
	end

	describe "fails a bad invoice:" do
		shared_examples "failure case" do |reason, filename, error_text|
                  specify description do
                    @upload = fixture_file_upload(filename)
                    InvoiceHelper.process_rows(@upload)
                    mis = MemnonInvoiceSubmission.last
                    expect(mis.filename).to eq filename
                    expect(mis.problems_by_row).not_to be_empty
                    expect(mis.problems_by_row.last).to match error_text
                    expect(mis.successful_validation).to eq false
                  end
		end
		include_examples "failure case", "with missing barcode", "Memnon Missing Barcode.xlsx", 'bad barcode'
		include_examples "failure case", "with barcodes not yet on SDA", "Memnon Not on SDA.xlsx", 'not on SDA'
		include_examples "failure case", "that contains an already billed physical object", "Memnon Already Billed.xlsx", 'already billed'
		include_examples "failure case", "with duplicate preservation master filenames", "Memnon Duplicate Pres File.xlsx", 'duplicate preservation'

	end

end
