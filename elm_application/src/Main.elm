module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>))


type Msg
    = ChangeUrl Url
    | ClickLink UrlRequest


type alias DocsRoute =
    ( String, Maybe String )


type alias Model =
    { navKey : Nav.Key
    , route : Maybe DocsRoute
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    ( { navKey = navKey, route = UrlParser.parse docsParser url }, Cmd.none )


docsParser : UrlParser.Parser (DocsRoute -> a) a
docsParser =
    UrlParser.map Tuple.pair (UrlParser.string </> UrlParser.fragment identity)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeUrl url ->
            ( { model | route = UrlParser.parse docsParser url }, Cmd.none )

        ClickLink urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.navKey <| Url.toString url )

                External url ->
                    ( model, Nav.load url )


shortcutContexts =
    [ ( "/i3", "i3" )
    , ( "/intellij", "IntelliJ" )
    , ( "/win10", "Win10" )
    , ( "/gothic2", "Gothic2" )
    , ( "/schismtracker", "Schismtracker" )
    ]


lookupContext : String -> List ShortCut
lookupContext context =
    case context of
        "i3" ->
            [ { kbCombo = "Meta+Shift+V", description = "Edit i3 config" }
            ]

        _ ->
            []


type alias ShortCut =
    { kbCombo : String
    , description : String
    }


view : Model -> Document Msg
view model =
    let
        inline =
            style "display" "inline-block"

        padded =
            style "padding" "10px"

        makeLink : ( String, String ) -> Html msg
        makeLink ( route, txt ) =
            a [ inline, padded, href route ] [ text txt ]

        menu =
            div [ style "padding" "10px", style "border-bottom" "1px solid #c0c0c0" ]
                (List.map makeLink shortcutContexts)

        title =
            case model.route of
                Just route ->
                    Tuple.first route
                        ++ (case Tuple.second route of
                                Just function ->
                                    "." ++ function

                                Nothing ->
                                    ""
                           )

                Nothing ->
                    "Invalid route"
    in
    { title = title ++ " shortcuts"
    , body =
        [ menu
        , h2 [] [ text title ]
        ]
    }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = ClickLink
        , onUrlChange = ChangeUrl
        }
