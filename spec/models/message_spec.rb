describe Message, :type => :model do
  let(:message) { FactoryBot.create :message }
  let(:valid_message) { FactoryBot.build :message }
  let(:invalid_message) { FactoryBot.build :message, :invalid }

  describe "FactoryBot" do
    it "provides a valid object" do
      expect(valid_message).to be_valid
    end
    it "provides an invalid object" do
      expect(invalid_message).to be_invalid
    end
  end

  describe "has required fields:" do
    specify "content" do
      expect(valid_message.content).not_to be_nil
      valid_message.content = nil
      expect(valid_message).to be_invalid
    end
  end
end
