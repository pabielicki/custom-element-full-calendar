module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events
import Json.Decode as Decode
import Json.Encode as Encode
import Time
import Url exposing (Url)


type alias Model =
    { events : List Event
    , timeZone : String
    }


type alias Event =
    { startTime : Time.Posix
    , endTime : Time.Posix
    , allDay : Bool
    , resources : List String
    , id : String
    }


type Msg
    = Noop
    | CalendarDateSelected String


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model [] "", Cmd.none )


type alias Flags =
    { baseUri : String
    , initialTime : Int
    }


main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = \_ -> Noop
        , onUrlChange = \_ -> Noop
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Document Msg
view model =
    let
        events =
            List.map (\e -> ( "0", "eeee", e )) model.events
    in
    { title = "test"
    , body =
        [ Html.node "full-calendar"
            [ Html.Attributes.property "calendarEvents" <|
                encodeEvents "0" events
            , Html.Attributes.property "calendar-timeZone" <|
                Encode.string model.timeZone
            , Html.Events.on "dateSelected" <|
                Decode.map CalendarDateSelected <|
                    Decode.at [ "target", "id" ] <|
                        Decode.string
            ]
            []
        ]
    }


encodeEvent : ( String, String, Event ) -> Encode.Value
encodeEvent ( messageId, textContent, event ) =
    Encode.object
        [ ( "title", Encode.string textContent )
        , ( "start", Encode.int (Time.posixToMillis event.startTime) )
        , ( "end", Encode.int (allDayEndTime event.endTime event.allDay) )
        , ( "allDay", Encode.bool event.allDay )
        , ( "id", Encode.string messageId )
        ]


encodeEvents : String -> List ( String, String, Event ) -> Encode.Value
encodeEvents id events =
    Encode.object
        [ ( "id", Encode.string id )
        , ( "events", Encode.list encodeEvent events )
        ]


allDayEndTime : Time.Posix -> Bool -> Int
allDayEndTime time allDay =
    case allDay of
        True ->
            time
                |> Time.posixToMillis
                -- Add 1 day to displaying event.
                |> (+) (1000 * 60 * 60 * 24)

        False ->
            Time.posixToMillis time
