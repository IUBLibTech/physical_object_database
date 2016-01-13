describe InvoiceController do
	render_views
	before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
	let!(:good_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000070013, digital_start: Time.now) }
	let!(:not_sda_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000070021, digital_start: nil) }
	let!(:billed_po) { FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000102782, digital_start: Time.now, billed: true, spread_sheet_filename: "Some Other Spreadhsheet") }

	# physical objects used in the bad invoice test
	let!(:po1) {FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000780546, digital_start: Time.now, billed: true)}
	let!(:po2) {FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000727679, digital_start: nil)}
	let!(:po3) {FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000646374, digital_start: Time.now)}
	let!(:po4) {FactoryGirl.create(:physical_object, :cdr, mdpi_barcode: 40000000649485, digital_start: Time.now)}

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


	describe "invalidates a bad invoice" do
		let(:mis) { MemnonInvoiceSubmission.last }
		before(:each) {
			@upload = fixture_file_upload("memnon_invoice_new_cases.xlsx")
			InvoiceHelper.process_rows(@upload)
		}

		context "fails on each test case" do
			it "finds 6 bad lines in the invoice" do
				expect(mis.problems_by_row.length).to eq 6
			end
			it "finds already billed" do
				expect(mis.problems_by_row[0]).to include "already billed"
				expect(mis.problems_by_row[1]).to include "already billed"
			end
			it "finds physical object not on SDA" do
				expect(mis.problems_by_row[2]).to include "not on SDA"
			end
			it "finds missing preservation master filename" do
				expect(mis.problems_by_row[3]).to include "missing preservation master filename, not on SDA"
			end
			it "finds bad barcode" do
				expect(mis.problems_by_row[4]).to include "bad barcode [0]"
			end
			it "finds a duplicate preservation master filename" do
				expect(mis.problems_by_row[5]).to include "duplicate preservation master filename"
			end
		end


	end

end
