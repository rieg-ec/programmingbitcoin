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
require_relative "../../lib/bitcoin/tx"
require_relative "../../lib/bitcoin/tx_in"

input_tx_id_1 = Helpers::Encoding.from_hex_to_bytes(
  "11d05ce707c1120248370d1cbf5561d22c4f83aeba0436792c82e0bd57fe2a2f"
)
input_tx_id_2 = Helpers::Encoding.from_hex_to_bytes(
  "51f61f77bd061b9a0da60d4bedaaf1b1fad0c11e65fdc744797ee22d20b03d15"
)

tx_in_1 = Bitcoin::TxIn.new(
  prev_tx_id: input_tx_id_1,
  prev_tx_index: 1
)

tx_in_2 = Bitcoin::TxIn.new(
  prev_tx_id: input_tx_id_2,
  prev_tx_index: 1
)

secret = 8_675_309
private_key = ECC::PrivateKey.new(secret)

tx_out = Bitcoin::TxOut.new(
  amount: (0.0429 * 100_000_000).to_i,
  script_pubkey: Bitcoin::Script.p2pkh_script(
    ECC::S256Point.decode_address("mwJn1YPMq7y5F8J3LkC5Hxg9PHyZ5K4cFv")
  )
)

tx_obj = Bitcoin::Tx.new(
  version: 1,
  tx_ins: [tx_in_1, tx_in_2],
  tx_outs: [tx_out],
  locktime: 0,
  testnet: true
)

puts tx_obj.sign_input(0, private_key)
puts tx_obj.sign_input(1, private_key)

puts Helpers::Encoding.from_bytes_to_hex(tx_obj.serialize)
