describe SearchController do
  render_views
  before(:each) { sign_in }
  

  describe "GET #index" do
    before(:each) do
      get :index
    end
    skip "WRITE TESTS"
  end

  describe "GET #search_results" do
    context "searching only physical objects" do
      pending "sets @physical_objects"
      pending "includes by barcode, call_number, title"
      pending "does not set @bins, @boxes"
      skip "WRITE TESTS"
    end
    context "searching all objects" do
      pending "same tests as for physical object"
      skip "WRITE TESTS"
    end
  end

  describe "GET #advanced_search" do
    skip "WRITE TESTS"
  end

end
