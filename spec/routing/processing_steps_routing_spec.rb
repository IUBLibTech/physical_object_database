describe ProcessingStepsController, type: :routing do
  describe "routing" do
    it "routes to #destroy" do
      expect(:delete => "/processing_steps/1").to route_to("processing_steps#destroy", :id => "1")
    end
  end
end
