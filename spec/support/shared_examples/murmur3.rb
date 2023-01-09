RSpec.shared_examples "murmur3" do
  before { described_class.extend(Helpers::Murmur3) }

  it "computes the correct murmur3 hash for different message and seeds" do
    [1_203_516_251, 669_393_163, 819_509_628, 3_765_971_536].each_with_index do |expected_hash, seed|
      expect(described_class.murmur_32("Bitcoin Guild rocks!", seed: seed)).to eq(expected_hash)
    end
    expect(described_class.murmur_32("Goodbye!", seed: 8_443_760_525)).to eq(468_028_502)
    [1_411_415_842, 2_371_772_749, 4_164_319_582, 2_164_673_664].each_with_index do |expected_hash, seed|
      expect(described_class.murmur_32("Bitcoin Guild rocks! #{seed}")).to eq(expected_hash)
    end
  end
end
