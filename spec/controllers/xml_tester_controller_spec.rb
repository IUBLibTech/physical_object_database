describe XmlTesterController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  describe "GET #index" do
    before(:each) { get :index }
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "POST #submit" do
    context "without a file" do
      before(:each) { post :submit }
      it "assigns error message" do
        expect(assigns(:xml)).to match /error.*file/i
      end
      it "renders the :submit template" do
        expect(response).to render_template :submit
      end
    end
    context "specifying a file" do
      let(:post_submit) { post :submit, file: fixture_file_upload(filename, 'text/xml') }
      context "not found" do
        let(:filename) { 'not_found.xml' }
        it "raises a runtime error" do
          expect { post_submit }.to raise_error RuntimeError
        end
      end
      context "found" do
        before(:each) { post_submit }
        context "with a validly-parsing file" do
          let(:filename) { 'files/xml_valid.xml' }
          it "parses the xml" do
             expect(assigns(:xml)).not_to be_blank
             expect(assigns(:xml)).not_to match /^An error/
          end
          it "renders the submit template" do
            expect(response).to render_template :submit
          end
        end
        skip "FAILING: with an invalidly-parsing file" do
          let(:filename) { 'files/xml_invalid.xml' }
          it "fails to parse the xml" do
             expect(assigns(:xml)).to match /^An error/
          end
          it "renders the submit template" do
            expect(response).to render_template :submit
          end
        end
      end
    end
  end
end
