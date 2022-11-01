require "bitcoin/tx"

RSpec.describe Bitcoin::Tx do
  describe "#initialize" do
    it do
      expect { described_class.new(1, [], [], 123_123) }.not_to raise_error
    end

    # it { described_class.parse("\xFF\xFF\xAA\xAA") }
  end
end
