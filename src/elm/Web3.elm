module Web3 exposing 
  ( Address
  , Block
  , BlockHash
  , Context
  , Hash
  , RpcError
  , Transaction

  , blockNumber
  , getBlockByNumber

  , formatAddress
  , formatBlockHash
  , formatHash
  )

import Json.Encode as JE exposing (Value)
import Task exposing (Task)

import Web3.Codec.Block as Block
import Web3.Codec as Codec
import Web3.Rpc as Rpc
import Web3.Types as Types


-- Re-export exposed types
type alias Address     = Types.Address
type alias Block       = Types.Block
type alias BlockHash   = Types.BlockHash
type alias Hash        = Types.Hash
type alias Transaction = Types.Transaction
type alias RpcError    = Rpc.Error
type alias Context     = String


-- API functions
getBlockByNumber : Context -> Int -> Task RpcError Block
getBlockByNumber ctx i =
  Rpc.request ctx "eth_getBlockByNumber" [JE.int i, JE.bool True] Block.block

blockNumber : Context -> Task RpcError Int
blockNumber ctx =
  Rpc.request ctx "eth_blockNumber" [] Codec.hexInt


-- Formatting utilities
formatAddress : Address -> String
formatAddress (Types.Address x) = x

formatBlockHash : BlockHash -> String
formatBlockHash (Types.BlockHash x) = x

formatHash : Hash -> String
formatHash (Types.Hash x) = x

