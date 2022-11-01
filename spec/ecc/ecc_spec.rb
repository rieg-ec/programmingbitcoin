require "ecc/field_element"
require "ecc/point"

RSpec.describe do
  describe "#initialize" do
    let(:prime) { 223 }
    let(:a) { ECC::FieldElement.new(0, prime) }
    let(:b) { ECC::FieldElement.new(7, prime) }
    let(:valid_points) { [[192, 105], [17, 56], [1, 193]] }
    let(:invalid_points) { [[200, 119], [42, 99]] }

    it do
      valid_points.each do |x, y|
        field_x = ECC::FieldElement.new(x, prime)
        field_y = ECC::FieldElement.new(y, prime)
        expect { ECC::Point.new(field_x, field_y, a, b) }.not_to raise_error
      end

      invalid_points.each do |x, y|
        field_x = ECC::FieldElement.new(x, prime)
        field_y = ECC::FieldElement.new(y, prime)
        expect { ECC::Point.new(field_x, field_y, a, b) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#+" do
    let(:prime) { 223 }
    let(:a) { ECC::FieldElement.new(0, prime) }
    let(:b) { ECC::FieldElement.new(7, prime) }
    let(:x1) { ECC::FieldElement.new(192, prime) }
    let(:y1) { ECC::FieldElement.new(105, prime) }
    let(:x2) { ECC::FieldElement.new(17, prime) }
    let(:y2) { ECC::FieldElement.new(56, prime) }
    let(:p1) { ECC::Point.new(x1, y1, a, b) }
    let(:p2) { ECC::Point.new(x2, y2, a, b) }

    it do
      expect((p1 + p2).x.num).to eq(170)
      expect((p1 + p2).y.num).to eq(142)
    end
  end

  describe "scalar times point" do
    it do
      prime = 223
      a = ECC::FieldElement.new(0, prime)
      b = ECC::FieldElement.new(7, prime)
      x = ECC::FieldElement.new(15, prime)
      y = ECC::FieldElement.new(86, prime)
      point = ECC::Point.new(x, y, a, b)
      scalar = 7

      expect((point * scalar).x).to eq(nil)
      expect((point * scalar).y).to eq(nil)

      expect((scalar * point).x).to eq(nil)
      expect((scalar * point).y).to eq(nil)

      prime = 223
      a = ECC::FieldElement.new(0, prime)
      b = ECC::FieldElement.new(7, prime)
      x = ECC::FieldElement.new(47, prime)
      y = ECC::FieldElement.new(71, prime)
      point = ECC::Point.new(x, y, a, b)
      expect((1 * point).x.num).to eq(47)
      expect((2 * point).x.num).to eq(36)
      expect((3 * point).x.num).to eq(15)
      expect((4 * point).x.num).to eq(194)
      expect((5 * point).x.num).to eq(126)
      expect((6 * point).x.num).to eq(139)
      expect((7 * point).x.num).to eq(92)
      expect((8 * point).x.num).to eq(116)
      expect((9 * point).x.num).to eq(69)
      expect((10 * point).x.num).to eq(154)
      expect((11 * point).x.num).to eq(154)
      expect((12 * point).x.num).to eq(69)
      expect((13 * point).x.num).to eq(116)
      expect((14 * point).x.num).to eq(92)
    end

    context "with another curve and points" do
    end
  end
end
