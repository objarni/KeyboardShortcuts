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


type alias Model =
    { navKey : Nav.Key
    , route : Maybe DocsRoute
    }


type alias DocsRoute =
    ( String, Maybe String )


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



-- Potential: unite all data, and let functions
-- shortcutContexts and lookupContext use that
-- structure instead of having these two almost
-- the same data structures


shortcutContexts =
    [ ( "/i3", "i3" )
    , ( "/intellij", "IntelliJ" )
    , ( "/win10", "Win10" )
    , ( "/gothic2", "Gothic2" )
    , ( "/schismtracker", "Schismtracker" )
    ]



-- Potential: Software has a 'any context' SubContext,
-- for kb shortcuts that are available in any context


type alias Software =
    List SubContext


type SubContext
    = SubContext String (List ShortCut)


lookupContext : String -> Software
lookupContext context =
    case context of
        "i3" ->
            [ SubContext "i3"
                [ { kbCombo = "Meta+Shift+V", description = "Edit i3 config" }
                ]
            ]

        "gothic2" ->
            [ SubContext "Inventory"
                [ { kbCombo = "Ctrl", description = "Drop item" }
                , { kbCombo = "Tab", description = "Inventory on/off" }
                , { kbCombo = "C", description = "Stats" }
                ]
            , SubContext "Not inventory"
                [ { kbCombo = "LMB", description = "Action (eat, talk, pick up)" }
                , { kbCombo = "Ctrl", description = "Jump" }
                , { kbCombo = "Tab", description = "Inventory on/off" }
                , { kbCombo = "C", description = "Stats" }
                ]
            ]

        _ ->
            []


type alias ShortCut =
    { kbCombo : String
    , description : String
    }


pad =
    style "padding" "10px"


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
            div [ pad, style "border-bottom" "1px solid #c0c0c0" ]
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
                    "Welcome to Keyboard Shortcuts helper!"

        context =
            case model.route of
                Just route ->
                    let
                        contextName =
                            Tuple.first route
                    in
                    lookupContext contextName

                Nothing ->
                    []

        header =
            h1 [] [ text ("Keyboard Shortcuts in " ++ title) ]

        shortcutHtml : ShortCut -> Html msg
        shortcutHtml shortcut =
            tr []
                [ td [ pad ] [ text shortcut.kbCombo ]
                , td [ pad ] [ text shortcut.description ]
                ]

        shortcutTable : List ShortCut -> Html msg
        shortcutTable shortcuts =
            table [ pad ] (List.map shortcutHtml shortcuts)

        subContextHtml : SubContext -> Html msg
        subContextHtml (SubContext name shortcuts) =
            div []
                [ div []
                    [ h1 [] [ text ("Context: " ++ name) ]
                    , shortcutTable shortcuts
                    ]
                ]

        contextHtml : Software -> Html msg
        contextHtml subContexts =
            div [] (List.map subContextHtml subContexts)
    in
    { title = title ++ " shortcuts"
    , body =
        [ menu
        , header
        , contextHtml context
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
