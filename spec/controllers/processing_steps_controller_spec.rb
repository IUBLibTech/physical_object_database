describe ProcessingStepsController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  describe "DELETE #destroy" do
    pending
  end

end
