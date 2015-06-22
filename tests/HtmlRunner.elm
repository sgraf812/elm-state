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

import Test.Stateful

main : Element
main = Element.runDisplay Test.Stateful.tests