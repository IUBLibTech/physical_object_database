describe PodReportsController, type: :controller do
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  let(:pod_report) { FactoryBot.create(:pod_report) }
  let(:valid_pr) { FactoryBot.build(:pod_report) }
  let(:invalid_pr) { FactoryBot.build(:invalid_pod_report) }

  describe "GET #index" do
    it "returns a success response" do
      pod_report
      get :index
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    before(:each) do
      allow(controller).to receive(:send_file)
      allow(controller).to receive(:render)
    end
    it "returns a success response" do
      get :show, id: pod_report.id, format: :xls
      expect(response).to be_success
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested pod_report" do
      pod_report
      expect {
        delete :destroy, {:id => pod_report.id}
      }.to change(PodReport, :count).by(-1)
    end

    it "redirects to the pod_reports list" do
      pod_report
      delete :destroy, {:id => pod_report.id}
      expect(response).to redirect_to(pod_reports_url)
    end
  end

end
