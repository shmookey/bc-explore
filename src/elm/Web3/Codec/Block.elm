module Web3.Codec.Block exposing (block)

import Json.Decode as JD exposing ((:=))
import Json.Decode.Extra as JDE exposing ((|:))

import Web3.Codec exposing (address, blockHash, date, hash, hexData, hexInt)
import Web3.Codec.Transaction exposing (transaction)
import Web3.Types exposing (..)

block : JD.Decoder Block
block =
  let
    difficulty       = hexInt
    extraData        = hexData
    gasLimit         = hexInt
    gasUsed          = hexInt
    hash'            = blockHash
    logsBloom        = hexData
    miner            = address
    nonce            = hexInt
    number           = hexInt
    parentHash       = blockHash
    receiptRoot      = hexData
    sha3Uncles       = hexData
    size             = hexInt
    stateRoot        = hexData
    timestamp        = date
    totalDifficulty  = hexInt
    transactions     = JD.oneOf [JD.list transaction, JD.succeed []]
    transactionsRoot = hexData
    uncles           = JD.list hexData
  in
    JD.succeed Block
      |: ("difficulty"       := difficulty)
      |: ("extraData"        := extraData)
      |: ("gasLimit"         := gasLimit)
      |: ("gasUsed"          := gasUsed)
      |: ("hash"             := hash')
      |: ("logsBloom"        := logsBloom)
      |: ("miner"            := miner)
      |: ("nonce"            := nonce)
      |: ("number"           := number)
      |: ("parentHash"       := parentHash)
      |: ("receiptRoot"      := receiptRoot)
      |: ("sha3Uncles"       := sha3Uncles)
      |: ("size"             := size)
      |: ("stateRoot"        := stateRoot)
      |: ("timestamp"        := timestamp)
      |: ("totalDifficulty"  := totalDifficulty)
      |: ("transactions"     := transactions)
      |: ("transactionsRoot" := transactionsRoot)
      |: ("uncles"           := uncles)

