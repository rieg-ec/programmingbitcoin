require "ecc/point"

RSpec.describe ECC::Point do
  let(:point) { described_class.new(-1, -1, 5, 7) }

  describe "#initialize" do
    context "with invalid points" do
      it "raises ArgumentError" do
        expect { described_class.new(-1, -2, 5, 7) }.to raise_error(ArgumentError)
      end
    end

    context "with valid points" do
      it "does not raises error" do
        expect { described_class.new(-1, -1, 5, 7) }.not_to raise_error
      end
    end

    context "infinity point" do
      it "does not raises error" do
        expect { described_class.new(nil, nil, 5, 7) }.not_to raise_error
      end
    end
  end

  describe "#==" do
    context "with equal curve and points" do
      let(:other_point) { described_class.new(-1, -1, 5, 7) }

      it { expect(point == other_point).to eq(true) }
    end
  end

  describe "#+" do
    let(:point) { described_class.new(-1, -1, 5, 7) }

    context "when p1 is inf" do
      let(:other_point) { described_class.new(nil, nil, 5, 7) }

      it do
        expect((other_point + point).y).to eq(-1)
        expect((other_point + point).x).to eq(-1)
      end
    end

    context "when p2 is inf" do
      let(:other_point) { described_class.new(nil, nil, 5, 7) }

      it do
        expect((point + other_point).y).to eq(-1)
        expect((point + other_point).x).to eq(-1)
      end
    end

    context "when p1 has same x as p2 and different y" do
      let(:other_point) { described_class.new(-1, 1, 5, 7) }

      it do
        expect((point + other_point).y).to eq(nil)
        expect((point + other_point).x).to eq(nil)
      end
    end

    context "when p1 has different x and different y as p2" do
      let(:other_point) { described_class.new(-1, 1, 5, 7) }

      it do
        expect((point + other_point).y).to eq(nil)
        expect((point + other_point).x).to eq(nil)
      end
    end

    context "when p1 and p2 are tangent, and y is not 0" do
      pending "add some examples to (or delete) #{__FILE__}"
    end

    context "when p1 and p2 are tangent and y is 0" do
      pending "add some examples to (or delete) #{__FILE__}"
    end
  end

  describe "#verify" do
    # use openSSL for examples
    # raise NotImplementedError
  end
end
