describe StatusTemplatesController do
  render_views
  before(:each) { sign_in; request.env['HTTP_REFERER'] = 'source_page' }

  describe "GET #index" do
    before(:each) { get :index }
    it "assigns all_workflow_status_templates" do
      expect(assigns(:all_workflow_status_templates).values.flatten.size).to eq WorkflowStatusTemplate.all.size
    end
    it "assigns all_condition_status_templates" do
      expect(assigns(:all_condition_status_templates).values.flatten.size).to eq ConditionStatusTemplate.all.size
    end
  end
end
