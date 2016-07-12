module Web3.Codec.Transaction exposing (transaction)

import Json.Decode as JD exposing ((:=))
import Json.Decode.Extra as JDE exposing ((|:))

import Web3.Codec exposing (address, blockHash, hash, hexData, hexInt)
import Web3.Types exposing (..)


transaction : JD.Decoder Transaction
transaction =
  let
    blockNumber      = hexInt
    from             = address
    gas              = hexInt
    gasPrice         = hexInt
    input            = hexData
    nonce            = hexInt
    to               = address
    transactionIndex = hexInt
    value            = hexInt
  in
    JD.succeed Transaction
      |: ("blockHash"        := blockHash)
      |: ("blockNumber"      := blockNumber)
      |: ("from"             := from)
      |: ("gas"              := gas)
      |: ("gasPrice"         := gasPrice)
      |: ("hash"             := hash)
      |: ("input"            := input)
      |: ("nonce"            := nonce)
      |: ("to"               := to)
      |: ("transactionIndex" := transactionIndex)
      |: ("value"            := value)

