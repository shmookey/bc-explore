module Web3.Codec.ABI exposing (..)

import Json.Decode as JD exposing ((:=))
import String exposing (left, dropLeft, split, toInt)
import Result as R exposing (Result(Ok, Err))
import Parser as P exposing (andThen, choice, symbol, token, or, succeed, (*>),(<*))
import Parser.Char as PC
import Parser.Number as PN
import List exposing (map)

import Web3.ABI as ABI


interface : JD.Decoder (List ABI.InterfaceField)
interface = JD.list <|
  JD.oneOf [ ABI.Function    `JD.map` functionType
           , ABI.Constructor `JD.map` constructorType 
           , ABI.Event       `JD.map` eventType
           ]

functionType : JD.Decoder ABI.FunctionType
functionType =
  JD.object3 ABI.FunctionType
    ( "name"    := JD.maybe JD.string)
    ( "inputs"  := JD.list functionValue)
    ( "outputs" := JD.list functionValue)

constructorType : JD.Decoder ABI.ConstructorType
constructorType =
  JD.object2 ABI.ConstructorType
    ( "inputs"  := JD.list functionValue)
    ( "outputs" := JD.list functionValue)

eventType : JD.Decoder ABI.EventType
eventType =
  JD.object3 ABI.EventType
    ( "name"      := JD.string)
    ( "inputs"    := JD.list eventValue)
    ( "anonymous" := JD.bool)

functionValue : JD.Decoder ABI.FunctionValue
functionValue =
  JD.object2 ABI.FunctionValue
    ( "name" := JD.string)
    ( "type" := type')

eventValue : JD.Decoder ABI.EventValue
eventValue =
  JD.object3 ABI.EventValue
    ( "name"    := JD.string)
    ( "type"    := type')
    ( "indexed" := JD.bool)

type' : JD.Decoder ABI.Type
type' =
  let
    typ         = [ uint, int, fixed, ufixed
                  , address, bool, string
                  , bytes, dbytes, array, darray ]

    uint        = quant   "uint"    ABI.UInt
    int         = quant   "int"     ABI.Int
    fixed       = quant2d "fixed"   ABI.Fixed
    ufixed      = quant2d "ufixed"  ABI.UFixed
    address     = basic   "address" ABI.Address
    bool        = basic   "bool"    ABI.Bool
    string      = basic   "string"  ABI.String
    bytes       = quant'  "bytes"   ABI.Bytes
    dbytes      = basic   "bytes"   ABI.DBytes

    array       = map2 ABI.Array fixedLen (PC.bracketed PN.integer)
    darray      = ABI.DArray `P.map` fixedLen <* token "[]"
    fixedLen    = choice [uint, int, fixed, ufixed, address, bool, string, bytes]

    basic   k t = token k *> succeed t
    quant   k t = token k *> size    `andThen` (t >> succeed)
    quant'  k t = token k *> size'   `andThen` (t >> succeed)
    quant2d k t = token k *> nXm     `andThen` (uncurry t >> succeed)
    nXm         = size <* symbol 'x' `andThen` ((,) >> flip P.map size)

    size        = size' `or` (succeed 256)
    size'       = [1..32] |> map ((*) 8) 
                          |> map (\x -> token (toString x) *> succeed x)
                          |> choice
  in 
    P.parse (choice typ) |> JD.customDecoder JD.string

map2 : (a -> b -> c) -> P.Parser a -> P.Parser b -> P.Parser c
map2 f p1 p2 = P.andThen p1 (\x -> P.map (f x) p2)

