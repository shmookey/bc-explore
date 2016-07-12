module Web3.Rpc exposing (Error, request)

import Json.Encode as JE
import Json.Decode as JD exposing ((:=))
import Http
import Time
import Task exposing (Task)


type Error
  = HttpError Http.Error

request : String -> String -> List JE.Value -> JD.Decoder a -> Task Error a
request url method args decoder =
  let
    body = JE.object
      [ ("jsonrpc", JE.string "2.0")
      , ("method" , JE.string method)
      , ("params" , JE.list args)
      , ("id"     , JE.int 0)
      ] |> JE.encode 0 |> Http.string

    settings =
      { timeout             = Time.second
      , onStart             = Nothing
      , onProgress          = Nothing
      , desiredResponseType = Nothing
      , withCredentials     = False
      }

    message =
      { verb    = "POST"
      , headers = []
      , url     = url
      , body    = body
      }
  in
    Http.send settings message
    |> Http.fromJson ("result" := decoder)
    |> Task.mapError HttpError

