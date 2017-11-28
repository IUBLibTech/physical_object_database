describe InvoiceController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }
  let(:mis) { FactoryBot.create :memnon_invoice_submission }
  let(:good_invoice) { fixture_file_upload("Memnon Good.xlsx") }
  let(:bad_invoice) { fixture_file_upload("memnon_invoice_new_cases.xlsx") }


  describe "GET index" do
    before(:each) do
      mis
      get :index
    end
    it "assigns @submissions" do
      expect(assigns[:submissions]).to eq [mis]
    end
    it "renders the index template" do
      expect(response).to render_template :index
    end
  end

  describe "POST submit" do
    context "with no file specified" do
      before(:each) { post :submit, xls_file: '' }
      it "flashes failure warning" do
        expect(flash[:warning]).to match /select an invoice/
      end
      it "renders the index" do
        expect(response).to render_template :index
      end
    end
    context "with an existing invoice" do
      before(:each) do
        mis.filename = good_invoice.original_filename
        mis.successful_validation = true
        mis.save!
        post :submit, xls_file: good_invoice
      end
      it "flashes a failure warning" do
        expect(flash[:warning]).to match /previously submitted/
      end
      it "redirects to invoice_controller_path" do
        expect(response).to redirect_to invoice_controller_path
      end
    end
    context "with a new invoice" do
      let(:submit) { post :submit, xls_file: good_invoice }
      it "submits the invoice for parsing" do
        expect(InvoiceHelper).to receive(:parse_invoice).with(good_invoice)
        submit
      end
      it "flashes a queued notice" do
        submit
        expect(flash[:notice]).to match /has been queued/
      end
      it "redirects to invoice_controller_path" do
        submit
        expect(response).to redirect_to invoice_controller_path
      end
    end
  end

  describe "GET failed_message" do
    before(:each) { get :failed_message, id: mis.id }
    it "assigns @mis" do
      expect(assigns(:mis)).to eq mis
    end
    it "renders the partial: invoice/failures_by_row" do
      expect(response).to render_template(partial: "invoice/_failures_by_row")
    end
  end

end
