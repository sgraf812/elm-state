module Test.Stateful where

import String
import Stateful exposing (Stateful)

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)


s = "state"

return5 = Stateful.return 5

nextId : Stateful Int Int
nextId =
  Stateful.get `Stateful.andThen` \id ->
  Stateful.put (id + 1) `Stateful.andThen` \_ ->
  Stateful.return id

threeIds : List Int
threeIds =
  fst <| Stateful.run
    (Stateful.sequence
      [ nextId
      , nextId
      , nextId
      ])
    3

tests : Test
tests =
  let
    unitTests =
      suite "unit tests"
        [ test "run pure computation" <| assertEqual (5, ()) (Stateful.run return5 ())
        , test "get" <| assertEqual ("error!", "error!") (Stateful.run Stateful.get "error!")
        , test "put" <| assertEqual ((), "OK") (Stateful.run (Stateful.put "OK") "error!")
        , test "modify" <| assertEqual ((), "ERROR!") (Stateful.run (Stateful.modify String.toUpper) "error!")
        , test "map" <| assertEqual ("5", ()) (Stateful.run (Stateful.map toString return5) ())
        , test "andThen - get, put and return old state" <|
               assertEqual
                 (5, 10)
                 (Stateful.run
                    (Stateful.get         `Stateful.andThen` \s -> -- s will be 5
                     Stateful.put (2 * s) `Stateful.andThen` \_ -> -- would be (), but the hidden state was doubled
                     Stateful.return s)
                    5) 
        , test "andMap - lifting +" <|
               assertEqual
                 (10, 5)
                 (Stateful.run
                    (Stateful.return (+) `Stateful.andMap` Stateful.get `Stateful.andMap` Stateful.get)
                    5)
        , test "sequence - arithmetic on the state" <|
               assertEqual
                 7
                 (snd <| Stateful.run
                   (Stateful.sequence
                     [ Stateful.modify (\x -> 2 * x)
                     , Stateful.modify (\x -> x - 1)
                     , Stateful.modify (\x -> x // 3)
                     , Stateful.modify (\x -> x + 5)
                     ])
                   4)
        ]
    examples =
      suite "examples"
        [ test "generating 3 auto-inc column IDs" <| assertEqual [3, 4, 5] threeIds
        ]
  in
    suite "Stateful tests"
      [ unitTests
      , examples
      ]