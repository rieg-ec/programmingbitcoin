require "pry"

require_relative "../../lib/ecc/field_element"
require_relative "../../lib/ecc/point"
require_relative "../../lib/ecc/Signature"
require_relative "../../lib/ecc/s256_point"
require_relative "../../lib/ecc/secp256k1_constants"
require_relative "../../lib/ecc/private_key"
require_relative "../../lib/bitcoin/tx"
require_relative "../../lib/helpers/encoding"
require_relative "../../lib/helpers/io"
require_relative "../../lib/bitcoin/script"
require_relative "../../lib/bitcoin/tx_in"

raw_tx = Helpers::Encoding.from_hex_to_bytes("01000000011c5fb4a35c40647bcacfeffcb8686f1e9925774c07a1dd26f6551f67bcc4a1750100\
00006b483045022100a08ebb92422b3599a2d2fcdaa11f8f807a66ccf33e7f4a9ff0a3c51f1b1e\
c5dd02205ed21dfede5925362b8d9833e908646c54be7ac6664e31650159e8f69b6ca539012103\
935581e52c354cd2f484fe8ed83af7a3097005b2f9c60bff71d35bd795f54b67ffffffff024042\
0f00000000001976a9141ec51b3654c1f1d0f4929d11a1f702937eaf50c888ac9fbb0d00000000\
001976a914d52ad7ca9b3d096a38e752c2018e6fbc40cdf26f88ac00000000")
puts Bitcoin::Tx.parse(StringIO.new(raw_tx), testnet: true)

puts "target: #{Helpers::Encoding.from_bytes_to_hex(ECC::S256Point.decode_address("miKegze5FQNCnGw6PKyqUbYUeBa4x2hFeM"))}"
puts "change: #{Helpers::Encoding.from_bytes_to_hex(ECC::S256Point.decode_address("mzx5YhAH9kNHtcN481u6WkjeHjYtVeKVh2"))}"

input_tx_id = Helpers::Encoding.from_hex_to_bytes(
  "75a1c4bc671f55f626dda1074c7725991e6f68b8fcefcfca7b64405ca3b45f1c"
)
tx_in = Bitcoin::TxIn.new(
  prev_tx_id: input_tx_id,
  prev_tx_index: 1
)

secret = 8_675_309
private_key = ECC::PrivateKey.new(secret)

tx_out = Bitcoin::TxOut.new(
  amount: (0.01 * 100_000_000).to_i,
  script_pubkey: Bitcoin::Script.p2pkh_script(
    ECC::S256Point.decode_address("miKegze5FQNCnGw6PKyqUbYUeBa4x2hFeM")
  )
)

change_tx = Bitcoin::TxOut.new(
  amount: (0.009 * 100_000_000).to_i,
  script_pubkey: Bitcoin::Script.p2pkh_script(
    ECC::S256Point.decode_address("mzx5YhAH9kNHtcN481u6WkjeHjYtVeKVh2")
  )
)

tx_outs = [tx_out, change_tx]

tx_obj = Bitcoin::Tx.new(
  version: 1,
  tx_ins: [tx_in],
  tx_outs: tx_outs,
  locktime: 0,
  testnet: true
)

tx_obj.sign_input(0, private_key)

puts Helpers::Encoding.from_bytes_to_hex(tx_obj.serialize)
