module Main where

import Basics exposing (..)
import Signal exposing (..)
import Graphics.Element exposing (..)

import ElmTest.Assertion as A
import ElmTest.Run as R
import ElmTest.Runner.Console as Console
import ElmTest.Runner.Element as Element
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

main : Element
main = Element.runDisplay tests