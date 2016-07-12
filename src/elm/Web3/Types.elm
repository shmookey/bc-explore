module Web3.Types exposing
  ( Address(Address)
  , Block
  , BlockHash(BlockHash)
  , Hash(Hash)
  , Transaction
  )

import Date exposing (Date)


type alias Block =
  { difficulty       : Int
  , extraData        : String 
  , gasLimit         : Int
  , gasUsed          : Int
  , hash             : BlockHash
  , logsBloom        : String 
  , miner            : Address
  , nonce            : Int
  , number           : Int
  , parentHash       : BlockHash
  , receiptRoot      : String
  , sha3Uncles       : String
  , size             : Int
  , stateRoot        : String
  , timestamp        : Date
  , totalDifficulty  : Int
  , transactions     : List Transaction
  , transactionsRoot : String
  , uncles           : List String
  }

type alias Transaction =
  { blockHash        : BlockHash
  , blockNumber      : Int
  , from             : Address
  , gas              : Int
  , gasPrice         : Int
  , hash             : Hash
  , input            : String
  , nonce            : Int
  , to               : Address
  , transactionIndex : Int
  , value            : Int
  }

type Address = Address String

type BlockHash = BlockHash String

type Hash = Hash String

