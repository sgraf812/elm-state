module Main where

import Basics exposing (..)
import Signal exposing (..)

import ElmTest.Assertion as A
import ElmTest.Run as R
import ElmTest.Runner.Console as Console
import ElmTest.Test exposing (..)
import IO.IO exposing (..)
import IO.Runner exposing (Request, Response)
import IO.Runner as Run

import Test.State as State

tests : Test
tests =
    suite "State tests"
    [ State.tests
    ]

console : IO ()
console = Console.runDisplay tests

port requests : Signal Request
port requests = Run.run responses console

port responses : Signal Response