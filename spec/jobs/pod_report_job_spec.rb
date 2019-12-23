describe PodReportJob, type: :job do
  describe "#perform" do
    before(:each) { allow(File).to receive(:write) }
    it "creates a PodReport" do
      expect { described_class.perform_now({}, {}) }.to change(PodReport, :count).by(1)
    end
    it "writes a File" do
      expect(File).to receive(:write)
      described_class.perform_now({}, {})
    end
  end
end
