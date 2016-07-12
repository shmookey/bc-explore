module Main exposing (main)

import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.App as HApp
import Color
import Time
import Task
import Material.Icons.Hardware as MIH

import Web3
import Blockchain


type alias Model = 
  { blockchain  : Blockchain.Model Msg
  , errors      : List String
  , apiEndpoint : String
  }

type Msg
  = EndpointInputChange String
  | EndpointInputApply
  | Error               String
  | ToBlockchain        Blockchain.Msg
  | SetApiEndpoint      String

init : (Model, Cmd Msg)
init =
  let
    url = "http://canchain.com:8545"
    (chain, cmd) = Blockchain.init 
      { envelope    = ToBlockchain
      , onError     = Error
      , apiEndpoint = url
      }
    model = 
      { blockchain  = chain
      , errors      = []
      , apiEndpoint = url
      }
  in
    (model, cmd)

subscriptions : Model -> Sub Msg
subscriptions model = Blockchain.subscriptions model.blockchain

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  let
    toBlockchain x =
      let
        (chain, cmd) = Blockchain.update x model.blockchain
        model'       = { model | blockchain = chain }
      in (model', cmd)
  
    error e =
      let
        errors' = e :: (model.errors)
        model'  = { model | errors = errors' }
        cmd     = Cmd.none
      in (model', cmd)

    setApiEndpoint x =
      let
        (chain, cmd) = Blockchain.init 
          { envelope    = ToBlockchain
          , onError     = Error
          , apiEndpoint = x
          }
        model' = { model | blockchain = chain, apiEndpoint = x, errors = [] }
      in (model', cmd)

    endpointInputChange x =
      let
        model' = { model | apiEndpoint = x }
        cmd    = Cmd.none
      in (model', cmd)

  in case msg of
    ToBlockchain x        -> toBlockchain x
    Error e               -> error e
    SetApiEndpoint x      -> setApiEndpoint x
    EndpointInputChange x -> endpointInputChange x
    EndpointInputApply    -> setApiEndpoint model.apiEndpoint

view : Model -> Html Msg
view model =
  let
    chain = Blockchain.view model.blockchain

    errors =
      let fmt x = H.div [HA.class "error"] [H.text (toString x)]
      in H.div [HA.class "errors"] <| List.map fmt model.errors

  in
    H.div []
      [ H.div [HA.class "pageHeader"] 
        [ H.div [HA.class "logo"] [H.text "Blockchain Explorer"]
        , H.form [HA.class "endpoint", HE.onSubmit EndpointInputApply]
          [ H.input [HA.value model.apiEndpoint, HE.onInput EndpointInputChange] [] 
          , H.span [HA.class "icon"] [MIH.device_hub Color.white 18]
          ]
        ]
      , errors
      , chain
      ]

main = HApp.program
  { init          = init
  , view          = view
  , update        = update
  , subscriptions = subscriptions
  }

