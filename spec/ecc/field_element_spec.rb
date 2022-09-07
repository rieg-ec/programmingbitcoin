require "ecc/field_element"

RSpec.describe ECC::FieldElement do
  let(:element) { described_class.new(7, 11) }

  describe "#initialize" do
    context "with invalid element" do
      it "raises StandardError" do
        expect { described_class.new(100, 100) }.to raise_error
      end
    end

    context "with valid element" do
      it "does not raises" do
        expect { described_class.new(7, 11) }.not_to raise_error
      end
    end
  end

  describe "#pow" do
    it "returns correct results" do
      expect(described_class.pow(3, 2)).to eq(9)
      expect(described_class.pow(3, 0)).to eq(1)
      expect(described_class.pow(3, 3)).to eq(27)
      expect(described_class.pow(0, 1)).to eq(0)
    end

    it "raises error" do
      expect { described_class.pow(0, 0) }.to raise_error
    end
  end

  describe "#==" do
    context "when comparing different elements" do
      let(:other_element) { described_class.new(5, 13) }

      it "returns false" do
        expect(element == other_element).to eq(false)
      end
    end

    context "when comparing equal elements" do
      let(:other_element) { described_class.new(7, 11) }

      it "returns true" do
        expect(element == other_element).to eq(true)
      end
    end
  end

  describe "#+" do
    let(:element) { described_class.new(7, 11) }

    context "when result overflows field order" do
      let(:other_element) { described_class.new(7, 11) }

      it { expect((element + other_element).num).to eq(3) }
    end

    context "when result does not overflow" do
      let(:other_element) { described_class.new(2, 11) }

      it { expect((element + other_element).num).to eq(9) }
    end

    context "when adding two elements from different fields" do
      let(:other_element) { described_class.new(2, 13) }

      it { expect { element + other_element }.to raise_error }
    end
  end

  describe "#-" do
    let(:element) { described_class.new(7, 11) }

    context "when result underflows 0" do
      let(:other_element) { described_class.new(9, 11) }

      it { expect((element - other_element).num).to eq(9) }
    end

    context "when result does not underflow" do
      let(:other_element) { described_class.new(2, 11) }

      it { expect((element - other_element).num).to eq(5) }
    end

    context "when substracting two elements from different fields" do
      let(:other_element) { described_class.new(2, 13) }

      it { expect { element - other_element }.to raise_error }
    end
  end

  describe "#*" do
    let(:element) { described_class.new(7, 11) }

    context "when result overflows field order" do
      let(:other_element) { described_class.new(2, 11) }

      it { expect((element * other_element).num).to eq(3) }
    end

    context "when result does not underflow" do
      let(:other_element) { described_class.new(1, 11) }

      it { expect((element * other_element).num).to eq(7) }
    end

    context "when multiplying two elements from different fields" do
      let(:other_element) { described_class.new(2, 13) }

      it { expect { element * other_element }.to raise_error }
    end
  end

  describe "#/" do
    let(:element) { described_class.new(8, 11) }

    context "when dividing different elements" do
      let(:other_element) { described_class.new(2, 11) }

      it { expect((element / other_element).num).to eq(4) }
    end

    context "when dividing same elements" do
      let(:other_element) { described_class.new(8, 11) }

      it { expect((element / other_element).num).to eq(1) }
    end

    context "when dividing two elements from different fields" do
      let(:other_element) { described_class.new(2, 13) }

      it { expect { element / other_element }.to raise_error }
    end
  end

  describe "#**" do
    let(:element) { described_class.new(2, 11) }

    context "when result overflows field order" do
      it { expect((element**4).num).to eq(5) }
    end

    context "when result does not underflow" do
      it { expect((element**3).num).to eq(8) }
    end

    context "with negative exponent" do
      it { expect((element**-3).num).to eq(7) }
      it { expect((element**-7).num).to eq(8) }
      it { expect((element**-6).num).to eq(5) }
    end
  end
end
