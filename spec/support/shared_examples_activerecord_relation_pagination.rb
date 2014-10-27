#
# requires arguments for:
# relation
#
shared_examples "provides pagination" do |relation|
  describe "provides pagination methods on @#{relation}" do
    specify "total_pages" do
      expect(assigns(relation)).to respond_to :total_pages
    end
  end
end

shared_examples "does not provide pagination" do |relation|
  describe "(absent) pagination methods on @#{relation}" do
    specify "total_pages (absent)" do
      expect(assigns(relation)).not_to respond_to :total_pages
    end
  end
end
