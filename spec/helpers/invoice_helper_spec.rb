describe InvoiceHelper do

  describe "::logger" do
    it "returns a logger instance" do
      expect(InvoiceHelper.logger).to be_a Logger
    end
  end
  describe "::parse_invoice(upload)" do
    let(:upload) { 'upload' }
    it "launches a process_rows in thread" do
      allow(InvoiceHelper).to receive :process_rows
      InvoiceHelper.parse_invoice(upload)
      expect(InvoiceHelper).to have_received(:process_rows).with(upload)
    end
  end
  describe "::process_rows" do
    let(:invalid_upload) { nil }
    let(:unsaved_upload) { Upload = Struct.new(:original_filename); Upload.new("") }
    let(:good_invoice) { fixture_file_upload("Memnon Good.xlsx") }
    let(:bad_invoice) { fixture_file_upload("memnon_invoice_new_cases.xlsx") }
    let(:bad_headers) { fixture_file_upload("memnon_invoice_bad_header.xlsx") }
    context "with an upload that does not respond to original_filename" do
      it "logs error 'Invalid upload'" do
        expect(InvoiceHelper.logger).to receive(:error).with(/Invalid upload/)
        InvoiceHelper.process_rows(invalid_upload)
      end
    end
    context "with an upload that does not save" do
      it "logs error 'Could not save'" do
        expect(InvoiceHelper.logger).to receive(:error).with(/Could not save invoice/)
        InvoiceHelper.process_rows(unsaved_upload)
      end
    end
    context "with a processable invoice" do
      let(:mis) { MemnonInvoiceSubmission.last }
      let!(:good_po) { FactoryBot.create(:physical_object, :cdr, mdpi_barcode: 40000000070013, digital_start: Time.now, title: "good_po") }
      let!(:po1) {FactoryBot.create(:physical_object, :cdr, mdpi_barcode: 40000000780546, digital_start: Time.now, billed: true, title: "already billed")}
      let!(:po2) {FactoryBot.create(:physical_object, :cdr, mdpi_barcode: 40000000727679, digital_start: nil, title: "not on sda")}
      let!(:po3) {FactoryBot.create(:physical_object, :cdr, mdpi_barcode: 40000000646374, digital_start: Time.now, title: "missing filename")}
      let!(:po4) {FactoryBot.create(:physical_object, :cdr, mdpi_barcode: 40000000649485, digital_start: Time.now, title: "duplicate filename")}
      let!(:unbilled_pos) { [po2, po3, po4] }

      context "with a good invoice" do
        let(:process) { InvoiceHelper.process_rows(good_invoice) }
        it "creates a successful invoice submission" do
          expect{ process }.to change(MemnonInvoiceSubmission, :count).by(1)
          expect(mis.filename).to eq "Memnon Good.xlsx"
          expect(mis.successful_validation).to eq true
        end
        it "bills physical objects" do
          process
          expect(good_po.billed?).to eq false
          good_po.reload
          expect(good_po.billed?).to eq true
        end
      end
      context "with an invoice with bad headers" do
        let(:process) { InvoiceHelper.process_rows(bad_headers) }
        it "creates a failed invoice submission" do
          expect{ process }.to change(MemnonInvoiceSubmission, :count).by(1)
          expect(mis.filename).to eq "memnon_invoice_bad_header.xlsx"
          expect(mis.bad_headers).to eq true
          expect(mis.successful_validation).to eq false
        end
        it "does not bill physical objects" do
          process
          expect(good_po.billed?).to eq false
          good_po.reload
          expect(good_po.billed?).to eq false
        end
        it "logs 'Bad headers'" do
          expect(InvoiceHelper.logger).to receive(:unknown).with(/Processing upload/)
          expect(InvoiceHelper.logger).to receive(:unknown).with(/Bad header/)
          process
        end
      end
      context "with a bad invoice" do
        let(:process) { InvoiceHelper.process_rows(bad_invoice) }
        it "creates a failed invoice submission" do
          expect{ process }.to change(MemnonInvoiceSubmission, :count).by(1)
          expect(MemnonInvoiceSubmission.last.filename).to eq "memnon_invoice_new_cases.xlsx"
          expect(MemnonInvoiceSubmission.last.successful_validation).to eq false
        end
        describe "fails on each test case" do
          before(:each) { process }
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
        it "does not bill physical objects" do
          process
	  unbilled_pos.each do |po|
            expect(po.billed?).to eq false
            po.reload
            expect(po.billed?).to eq false
          end
        end
      end
    end
  end
end