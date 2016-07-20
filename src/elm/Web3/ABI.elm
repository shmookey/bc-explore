module Web3.ABI exposing (..)


type InterfaceField
  = Function    FunctionType
  | Constructor ConstructorType
  | Event       EventType

type alias FunctionType =
  { fnName      : Maybe String
  , fnInputs    : List FunctionValue
  , fnOutputs   : List FunctionValue
  }

type alias ConstructorType =
  { ctorInputs  : List FunctionValue
  , ctorOutputs : List FunctionValue
  }

type alias FunctionValue =
  { fvalName    : String
  , fvalType    : Type
  }

type alias EventType =
  { evName      : String
  , evInputs    : List EventValue
  , evAnonymous : Bool
  }

type alias EventValue =
  { evalName    : String
  , evalType    : Type
  , evalIndexed : Bool
  }

type Type
  = UInt   Int     -- n bits
  | Int    Int     -- n bits
  | Fixed  Int Int -- n.m bits
  | UFixed Int Int -- n.m bits

  | Address
  | Bool
  | String

  | Bytes Int
  | Array Type Int

  | DBytes
  | DArray Type

