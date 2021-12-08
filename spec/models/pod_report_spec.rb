describe PodReport, type: :model do
  let(:pod_report) { FactoryBot.create :pod_report }
  let(:valid_pr) { FactoryBot.build :pod_report }
  let(:invalid_pr) { FactoryBot.build :pod_report, :invalid }

  describe "FactoryBot" do
    it "gets a valid object by default" do
      expect(valid_pr).to be_valid
    end
    it "gets an invalid object by request" do
      expect(invalid_pr).to be_invalid
    end
  end

  describe "has required attributes" do
    it "requires a filename" do
      valid_pr.filename = nil
      expect(valid_pr).not_to be_valid
    end
    it "requires a unique filename" do
      valid_pr.filename = pod_report.filename
      expect(valid_pr).not_to be_valid
    end
    it "requires a status" do
      valid_pr.status = nil
      expect(valid_pr).not_to be_valid
    end
  end

  describe "#destroy" do
    context "with a file present" do
      before(:each) { allow(File).to receive(:delete) }
      it "calls File.delete" do
        expect(File).to receive(:delete)
        pod_report.destroy
      end
    end
    context "with a file missing" do
      it "calls File.delete and catches the error" do
        expect(File).to receive(:delete)
        expect { pod_report.destroy }.not_to raise_error
      end
    end
  end

  describe "complete?" do
    context "when status is Available" do
      before(:each) { pod_report.status = 'Available' }
      it "returns true" do
        expect(pod_report.complete?).to be_truthy
      end
    end
    context "when status is other than Available" do
      before(:each) { pod_report.status = 'RUNNING' }
      it "returns true" do
        expect(pod_report.complete?).to be_falsey
      end
    end
  end

  describe "#full_path" do
    it "returns a Pathname" do
      expect(pod_report.full_path).to be_a Pathname
    end
  end

  describe "#display_size" do
    context "with file missing" do
      it "returns 0" do
        expect(pod_report.display_size).to eq '0'
      end
    end
    context "with file present" do
      context "with incomplete status" do
        before(:each) do
          allow(pod_report).to receive(:complete?).and_return(false)
          allow(pod_report).to receive(:size).and_return(42 * 2**20)
          allow(pod_report).to receive(:status).and_return("42% (ETA: tomorrow)")
        end
        it "returns current, projected total" do
          expect(pod_report.display_size).to match /projected total/
        end
      end
      context "with complete status" do
        before(:each) do
          allow(pod_report).to receive(:complete?).and_return(true)
        end
        context "with a small file" do
          before(:each) do
            allow(pod_report).to receive(:size).and_return(42)
          end
          it "returns minimum of 1 MB" do
            expect(pod_report.display_size).to eq '1'
          end
        end
        context "with a large file" do
          before(:each) do
            allow(pod_report).to receive(:size).and_return(42 * 2**20)
          end
          it "returns minimum of 1 MB" do
            expect(pod_report.display_size).to eq '42'
          end
        end
      end
    end
  end
 
  describe "#size" do
    context "with file missing" do
      it "returns 0" do
        expect(pod_report.size).to eq 0
      end
    end
    context "with file present" do
      let(:size) { 42 }
      before(:each) do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:size).and_return(42)
      end
      it "returns filesize in MB" do
        expect(pod_report.size).to eq size
      end
    end
  end
end
