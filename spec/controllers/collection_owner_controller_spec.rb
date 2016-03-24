describe CollectionOwnerController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  describe "#index" do
    pending "write index tests"
  end

  describe "#show" do
    pending "write show tests"
  end

  describe "#search" do
    pending "write search tests"
  end

end
