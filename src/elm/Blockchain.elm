module Blockchain exposing (Model, Msg, init, view, subscriptions, update)

import Array exposing (Array)
import Array.Extra as AE
import Cmd.Extra as CmdX
import Html as H exposing (Html)
import Html.App as HApp
import Html.Attributes as HA
import Html.Events as HE
import Task
import Color
import Material.Icons.Communication as MIC
import Material.Icons.Action as MIA
import Date.Format as DF
import Time

import Web3


type alias Model a =
  { blocks   : Array (Block, BlockViewState)
  , settings : Settings a
  }

type BlockViewState
  = Collapsed
  | Summary
  | Detail

type alias Settings a =
  { envelope    : Msg -> a
  , onError     : String -> a
  , apiEndpoint : String
  }

type Msg
  = RequestBlock       Int
  | RequestBlockNumber
  | CollapseBlock      Int
  | ExpandBlock        Int
  | RpcBlockData       Int Web3.Block
  | RpcBlockNumber     Int
  | RpcBlockError      Int Web3.RpcError
  | RpcError           Web3.RpcError

type Block
  = BlockInfo  Web3.Block
  | BlockError Web3.RpcError
  | BlockStub

init : Settings a -> (Model a, Cmd a)
init settings =
  let
    model = { blocks   = Array.empty 
            , settings = settings }
    cmd   = CmdX.message (settings.envelope RequestBlockNumber)
  in
    (model, cmd)

subscriptions : Model a -> Sub a
subscriptions model =
  let msg = model.settings.envelope RequestBlockNumber
  in Time.every Time.second (\_ -> msg)

update : Msg -> Model a -> (Model a, Cmd a)
update msg model =
  let
    url = model.settings.apiEndpoint

    perform err ok = 
      let f = model.settings.envelope
      in Task.perform (err >> f) (ok >> f)

    requestBlock i =
      let onError   = RpcBlockError i
          onSuccess = RpcBlockData i
          cmdGet    = Web3.getBlockByNumber url i |> perform onError onSuccess
          cmdView   = CmdX.message <| model.settings.envelope (ExpandBlock i)
          cmd       = Cmd.batch [cmdGet, cmdView]
      in (model, cmd)

    requestBlockNumber =
      let cmd = Web3.blockNumber url |> perform RpcError RpcBlockNumber
      in (model, cmd)

    collapseBlock i =
      let blocks' = modify (\(x,_) -> (x, Collapsed)) i model.blocks
          model'  = { model | blocks = blocks' }
          cmd     = Cmd.none
      in (model', cmd)

    expandBlock i =
      let blocks' = modify (\(x,_) -> (x, Detail)) i model.blocks
          model'  = { model | blocks = blocks' }
          cmd     = Cmd.none
      in (model', cmd)

    rpcBlockData i x =
      let blocks' = modify (\(_,v) -> (BlockInfo x, v)) i model.blocks
          model'  = { model | blocks = blocks' }
          cmd     = Cmd.none
      in (model', cmd)

    rpcBlockNumber n =
      let blocks' = AE.resizelRepeat n (BlockStub, Collapsed) model.blocks
          model'  = { model | blocks = blocks' }
          cmd     = Cmd.none
      in (model', cmd)

    rpcBlockError i x =
      let blocks' = modify (\(_,v) -> (BlockError x, v)) i model.blocks
          model'  = { model | blocks = blocks' }
          cmd     = Cmd.none
      in (model', cmd)

    rpcError x =
      let msg = toString x
          cmd = CmdX.message <| model.settings.onError msg
      in (model, cmd)

  in case msg of
    RequestBlock i     -> requestBlock i
    RequestBlockNumber -> requestBlockNumber
    CollapseBlock i    -> collapseBlock i
    ExpandBlock i      -> expandBlock i
    RpcBlockData i x   -> rpcBlockData i x
    RpcBlockNumber n   -> rpcBlockNumber n
    RpcBlockError i x  -> rpcBlockError i x
    RpcError x         -> rpcError x


view : Model a -> Html a
view model =
  let
    blocks  = Array.toList model.blocks |> List.indexedMap block
    block i = viewBlock i >> HApp.map model.settings.envelope
  in 
    H.div [HA.class "blockchain"] (List.reverse blocks)

viewBlock : Int -> (Block, BlockViewState) -> Html Msg
viewBlock i (block, viewState) =
  let
    loadBlock     = RequestBlock i
    collapseBlock = CollapseBlock i
    expandBlock   = ExpandBlock i

    field cls name label value =
      field' cls name label (H.text value)
    
    field' cls name label value =
      H.div [HA.class <| "field " ++ name ++ " " ++ cls]
        [ H.div [HA.class "label"] [H.text label]
        , H.div [HA.class "value"] [value]
        ]

    blockFrame cls attrs header body =
      H.div ((HA.class <| "block " ++ cls)::attrs)
        [ H.div [HA.class "header"]
          [ H.div [HA.class "blockNumber"] [H.text <| "Block " ++ (toString i)]
          , header
          ]
        , body
        ]

    blockHeaderContent x =
      H.div [HA.class "header-content"]
        [ H.div [HA.class "transaction-count numbericon"]
          [ transactionIcon
          , H.span [HA.class "text"] [H.text <| toString (List.length x.transactions)]
          ]
        ]
        
    blockSummary x =
      blockFrame "data summary" [HE.onClick expandBlock]
        (blockHeaderContent x) 
        (H.div [] [])

    blockCollapsed x =
      blockFrame "data collapsed" [HE.onClick expandBlock] 
        (blockHeaderContent x) 
        (H.div [] [])

    blockDetail x =
      blockFrame "data detail" [HE.onClick collapseBlock]
        (blockHeaderContent x) 
        ( H.div [] 
          [ field  ""    "timestamp"        "Timestamp"         (DF.formatISO8601 x.timestamp)
          , field' ""    "miner"            "Mined by"          (address x.miner)
          , field  "num" "difficulty"       "Difficulty"        (toString x.difficulty)
          , field  "num" "gasLimit"         "Gas limit"         (toString x.gasLimit)
          , field  "num" "gasUsed"          "Gas used"          (toString x.gasUsed)
          , field' ""    "hash"             "Hash"              (blockHash x.hash)
          , field  "num" "size"             "Size"              (toString x.size)
          , field  "num" "nonce"            "Nonce"             (toString x.nonce)
          , field  "num" "totalDifficulty"  "Total difficulty"  (toString x.totalDifficulty)
          , field' ""    "parentHash"       "Parent hash"       (blockHash x.parentHash)
          , field  "hex" "extraData"        "Extra data"        x.extraData
          , field  "hex" "logsBloom"        "Logs bloom"        x.logsBloom
          , field  "hex" "receiptRoot"      "Receipt root"      x.receiptRoot
          , field  "hex" "sha3Uncles"       "SHA3 uncles"       x.sha3Uncles
          , field  "hex" "stateRoot"        "State root"        x.stateRoot
          , field  "hex" "transactionsRoot" "Transactions root" x.transactionsRoot
          , field  "hex" "uncles"           "Uncles"            (toString x.uncles)
          , field' ""    "transactions"     "Transactions"      (transactions x.transactions)
          ])
    
    transactions xs =
      H.div [HA.class "transactions"]
        (List.indexedMap transaction xs)

    transaction i x =
      H.div [HA.class "transaction"]
        [ field' ""    "from"             "From"          (address x.from)
        , field' ""    "to"               "To"            (address x.to)
        , field  "num" "value"            "Value"         (toString x.value)
        , field' ""    "hash"             "Hash"          (hash x.hash)
        , field' ""    "blockHash"        "Block hash"    (blockHash x.blockHash)
        , field  "num" "gas"              "Gas"           (toString x.gas)
        , field  "num" "gasPrice"         "Gas price"     (toString x.gasPrice)
        , field  "num" "nonce"            "Nonce"         (toString x.nonce)
        , field  "num" "blockNumber"      "Block number"  (toString x.blockNumber)
        , field  "num" "transactionIndex" "Index"         (toString x.transactionIndex)
        , field  "hex" "input"            "Input"         x.input
        ]

    blockError x =
      let
        err = "Error retrieving block: " ++ (toString x)
      in
        blockFrame "error collapsed" [HE.onClick loadBlock]
          (H.div [] [H.text (toString x)]) 
          (H.div [] []) 

    blockStub =
      blockFrame "stub collapsed" [HE.onClick loadBlock] 
        (H.div [HA.class "expander"] [H.text "- click to expand -"])
        (H.div [] [])

    address x =
      let
        addr = Web3.formatAddress x
      in
        H.span [HA.class "address"] 
          [ addressIcon
          , H.span [HA.class "text"] [H.text addr]
          ]

    blockHash x = 
      let
        bhash = Web3.formatBlockHash x
      in
        H.span [HA.class "blockHashVal"] [H.text bhash]
        
    hash x =
      let
        hash' = Web3.formatHash x
      in
        H.span [HA.class "plainHash"] [H.text hash']

  in case (block, viewState) of
    ( BlockInfo x  , Summary   ) -> blockSummary x
    ( BlockInfo x  , Collapsed ) -> blockCollapsed x
    ( BlockInfo x  , Detail    ) -> blockDetail x
    ( BlockError x , _         ) -> blockError x
    ( BlockStub    , _         ) -> blockStub

addressIcon = H.span [HA.class "icon"] [MIC.contact_mail Color.black 15]
transactionIcon = H.span [HA.class "icon"] [MIA.payment Color.black 15]

modify : (a -> a) -> Int -> Array a -> Array a
modify f i xs = 
  Array.get i xs 
  |> Maybe.map (\x -> Array.set i (f x) xs)
  |> Maybe.withDefault xs

