describe ApplicationController do
  describe "#tm_form"
  describe "private methods" do
    describe "#user_not_authorized" do
      it "flashes warning" do
        allow(subject).to receive :redirect_to
        subject.send(:user_not_authorized)
        expect(flash[:warning]).to match /not authorized/i
      end
      describe "redirects" do
        context "with a request.referrer set" do
          before(:each) { request.env['HTTP_REFERER'] = 'source_page' }
          it "redirects to request.referrer" do
            allow(subject).to receive :redirect_to
            subject.send(:user_not_authorized)
            expect(subject).to have_received(:redirect_to).with('source_page')
          end
        end
        context "without a request.referrer set" do
          before(:each) { request.env['HTTP_REFERER'] = nil }
          it "redirects to root_path" do
            allow(subject).to receive :redirect_to
            subject.send(:user_not_authorized)
            expect(subject).to have_received(:redirect_to).with(root_path)
          end
        end
      end
    end
  end
end
