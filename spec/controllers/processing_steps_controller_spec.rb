describe ProcessingStepsController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:formats) { ['CD-R'] }
  let!(:processing_step) { FactoryGirl.create :processing_step, :with_formats, formats: formats }

  describe "DELETE #destroy" do
    let(:delete_destroy) { delete :destroy, id: processing_step.id }
    it "assigns the requested object" do
      delete_destroy
      expect(assigns(:processing_step)).to eq processing_step
    end
    it "destroys the requested object" do
      expect { delete_destroy }.to change(ProcessingStep, :count).by(-1)
    end
    it "redirects to :back" do
      delete_destroy
      expect(response).to redirect_to "source_page"
    end
  end

end
