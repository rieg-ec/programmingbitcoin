# encoding: ascii-8bit

require "bitcoin/merkle_tree"
require "helpers/encoding"

RSpec.describe Bitcoin::MerkleTree do
  include Helpers::Encoding

  describe ".merkle_root" do
    let(:nodes) do
      %w[
        c117ea8ec828342f4dfb0ad6bd140e03a50720ece40169ee38bdc15d9eb64cf5
        c131474164b412e3406696da1ee20ab0fc9bf41c8f05fa8ceea7a08d672d7cc5
        f391da6ecfeed1814efae39e7fcb3838ae0b02c02ae7d0a5848a66947c0727b0
        3d238a92a94532b946c90e19c49351c763696cff3db400485b813aecb8a13181
        10092f2633be5f3ce349bf9ddbde36caa3dd10dfa0ec8106bce23acbff637dae
        7d37b3d54fa6a64869084bfd2e831309118b9e833610e6228adacdbd1b4ba161
        8118a77e542892fe15ae3fc771a4abfd2f5d5d5997544c3487ac36b5c85170fc
        dff6879848c2c9b62fe652720b8df5272093acfaa45a43cdb3696fe2466a3877
        b825c0745f46ac58f7d3759e6dc535a1fec7820377f24d4c2c6ad2cc55c0cb59
        95513952a04bd8992721e9b7e2937f1c04ba31e0469fbe615a78197f68f52b7c
        2e6d722e5e4dbdf2447ddecc9f7dabb8e299bae921c99ad5b0184cd9eb8e5908
        b13a750047bc0bdceb2473e5fe488c2596d7a7124b4e716fdd29b046ef99bbf0
      ].map { |node| from_hex_to_bytes(node) }
    end
    let(:merkle_root) { "acbcab8bcc1af95d8d563b77d24c3d19b18f1486383d75a5085c4e86c86beed6" }

    it "calculates the merkle root" do
      expect(from_bytes_to_hex(described_class.merkle_root(nodes))).to eq merkle_root
    end
  end

  describe ".merkle_parent_level" do
    let(:nodes) do
      %w[
        c117ea8ec828342f4dfb0ad6bd140e03a50720ece40169ee38bdc15d9eb64cf5
        c131474164b412e3406696da1ee20ab0fc9bf41c8f05fa8ceea7a08d672d7cc5
        f391da6ecfeed1814efae39e7fcb3838ae0b02c02ae7d0a5848a66947c0727b0
        3d238a92a94532b946c90e19c49351c763696cff3db400485b813aecb8a13181
        10092f2633be5f3ce349bf9ddbde36caa3dd10dfa0ec8106bce23acbff637dae
      ].map { |node| from_hex_to_bytes(node) }
    end

    it "returns the merkle parent level" do
      first_join = described_class.merkle_parent_level(nodes[0..1])
      expect(from_bytes_to_hex(first_join.first)).to eq "8b30c5ba100f6f2e5ad1e2a742e5020491240f8eb514fe97c713c31718ad7ecd"
      second_join = described_class.merkle_parent_level(nodes[2..3])
      expect(from_bytes_to_hex(second_join.first)).to eq "7f4e6f9e224e20fda0ae4c44114237f97cd35aca38d83081c9bfd41feb907800"
      third_join = described_class.merkle_parent_level(nodes[4..4])
      expect(from_bytes_to_hex(third_join.first)).to eq "3ecf6115380c77e8aae56660f5634982ee897351ba906a6837d15ebc3a225df0"
    end
  end

  describe "#populate_tree" do
    context "when all hashes are given" do
      let(:hex_hashes) do
        %w[
          9745f7173ef14ee4155722d1cbf13304339fd00d900b759c6f9d58579b5765fb
          5573c8ede34936c29cdfdfe743f7f5fdfbd4f54ba0705259e62f39917065cb9b
          82a02ecbb6623b4274dfcab82b336dc017a27136e08521091e443e62582e8f05
          507ccae5ed9b340363a0e6d765af148be9cb1c8766ccc922f83e4ae681658308
          a7a4aec28e7162e1e9ef33dfa30f0bc0526e6cf4b11a576f6c5de58593898330
          bb6267664bd833fd9fc82582853ab144fece26b7a8a5bf328f8a059445b59add
          ea6d7ac1ee77fbacee58fc717b990c4fcccf1b19af43103c090f601677fd8836
          457743861de496c429912558a106b810b0507975a49773228aa788df40730d41
          7688029288efc9e9a0011c960a6ed9e5466581abf3e3a6c26ee317461add619a
          b1ae7f15836cb2286cdd4e2c37bf9bb7da0a2846d06867a429f654b2e7f383c9
          9b74f89fa3f93e71ff2c241f32945d877281a6a50a6bf94adac002980aafe5ab
          b3a92b5b255019bdaf754875633c2de9fec2ab03e6b8ce669d07cb5b18804638
          b5c0b915312b9bdaedd2b86aa2d0f8feffc73a2d37668fd9010179261e25e263
          c9d52c5cb1e557b92c84c52e7c4bfbce859408bedffc8a5560fd6e35e10b8800
          c555bc5fc3bc096df0a0c9532f07640bfb76bfe4fc1ace214b8b228a1297a4c2
          f9dbfafc3af3400954975da24eb325e326960a25b87fffe23eef3e7ed2fb610e
        ]
      end
      let(:byte_hashes) { hex_hashes.map { |h| from_hex_to_bytes(h) } }
      let(:flag_bits) { Array.new(31, 1) }
      let(:tree) { described_class.new(hex_hashes.size) }

      it "properly populates the tree" do
        tree.populate_tree(flag_bits, byte_hashes)
        root = "597c4bafe3832b17cbbabe56f878f4fc2ad0f6a402cee7fa851a9cb205f87ed1"

        expect(from_bytes_to_hex(tree.root)).to eq(root)
      end
    end

    context "when some hashes are given" do
      let(:hex_hashes) do
        %w[
          ba412a0d1480e370173072c9562becffe87aa661c1e4a6dbc305d38ec5dc088a
          7cf92e6458aca7b32edae818f9c2c98c37e06bf72ae0ce80649a38655ee1e27d
          34d9421d940b16732f24b94023e9d572a7f9ab8023434a4feb532d2adfc8c2c2
          158785d1bd04eb99df2e86c54bc13e139862897217400def5d72c280222c4cba
          ee7261831e1550dbb8fa82853e9fe506fc5fda3f7b919d8fe74b6282f92763ce
          f8e625f977af7c8619c32a369b832bc2d051ecd9c73c51e76370ceabd4f25097
          c256597fa898d404ed53425de608ac6bfe426f6e2bb457f1c554866eb69dcb8d
          6bf6f880e9a59b3cd053e6c7060eeacaacf4dac6697dac20e4bd3f38a2ea2543
          d1ab7953e3430790a9f81e1c67f5b58c825acf46bd02848384eebe9af917274c
          dfbb1a28a5d58a23a17977def0de10d644258d9c54f886d47d293a411cb62261
        ]
      end
      let(:byte_hashes) { hex_hashes.map { |h| from_hex_to_bytes(h) } }
      let(:flag_bits) { [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0] }
      let(:tree) { described_class.new(3519) }

      it "properly populates the tree" do
        tree.populate_tree(flag_bits, byte_hashes)
        root_solution = "ef445fef2ed495c275892206ca533e7411907971013ab83e3b47bd0d692d14d4"

        expect(from_bytes_to_hex(tree.root)).to eq(root_solution)
      end
    end
  end
end
