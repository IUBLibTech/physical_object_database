describe WelcomeController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  describe "GET index" do
    before(:each) { get :index }
    it "renders :index" do
      expect(response).to render_template :index
    end
  end

end
