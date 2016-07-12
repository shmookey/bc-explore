module Web3.Codec exposing
  ( address
  , blockHash
  , date
  , hash
  , hexData
  , hexInt
  )

import ParseInt as PI
import Json.Decode as JD
import String
import Result exposing (Result(Ok, Err))
import Date exposing (Date)
import Time

import Web3.Types exposing (..)


hexInt : JD.Decoder Int
hexInt =
  let
    parseHexInt = PI.parseIntHex >> Result.formatError toString
  in
    JD.customDecoder hexData parseHexInt

hexData : JD.Decoder String
hexData =
  let
    hex x = case (String.left 2 x) of 
      "0x" -> Ok  <| String.dropLeft 2 x
      bad  -> Err <| "Found '" ++ bad ++ "', expecting 0x."
  in
    JD.customDecoder JD.string hex

address : JD.Decoder Address
address = JD.map Address hexData

blockHash : JD.Decoder BlockHash
blockHash = JD.map BlockHash hexData

hash : JD.Decoder Hash
hash = JD.map Hash hexData

date : JD.Decoder Date
date = JD.map (toFloat >> (*) 1000 >> Date.fromTime) hexInt

