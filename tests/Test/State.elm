module Test.State where

import String
import State

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)


s = "state"

return5 = State.new 5
      

tests : Test
tests =
  let
    unitTests =
      suite "unit tests"
        [ test "run pure computation" <| assertEqual (5, ()) (State.run return5 ())
        , test "get" <| assertEqual ("error!", "error!") (State.run State.get "error!")
        , test "put" <| assertEqual ((), "OK") (State.run (State.put "OK") "error!")
        , test "modify" <| assertEqual ((), "ERROR!") (State.run (State.modify String.toUpper) "error!")
        , test "map" <| assertEqual ("5", ()) (State.run (State.map toString return5) ())
        , test "andThen - get, put and return old state" <|
               assertEqual
                 (5, 10)
                 (State.run
                    (State.get         `State.andThen` \s -> -- s will be 5
                     State.put (2 * s) `State.andThen` \_ -> -- would be (), but the hidden state was doubled
                     State.new s)
                    5) 
        , test "andMap - lifting +" <|
               assertEqual
                 (10, 5)
                 (State.run
                    (State.new (+) `State.andMap` State.get `State.andMap` State.get)
                    5)
        , test "sequence - arithmetic on the state" <|
               assertEqual
                 7
                 (snd <| State.run
                   (State.sequence
                     [ State.modify (\x -> 2 * x)
                     , State.modify (\x -> x - 1)
                     , State.modify (\x -> x // 3)
                     , State.modify (\x -> x + 5)
                     ])
                   4)
        ]
    in
      unitTests