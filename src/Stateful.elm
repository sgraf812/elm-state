module Stateful
  ( Stateful
  , return, run, get, put, modify
  , map, andMap, andThen, sequence
  ) where


{-| # Stateful

This library enables stateful computations, e.g. functions which, besides returning a value, can read and modify hidden state values.

Think of a random generator which produces a random value but needs to read and modify a seed value.

# Primitives
@docs Stateful, return, run, get, put, modify
# Composition
@docs map, andMap, andThen, sequence

-}


{-| A type representing stateful computations.
Access to the state of type `s` is granted through primitive functions.
The purpose of the computation is its evaluation to something of type `a`, thereby transforming the given state along the way.
Its internal representation is that of a function `s -> (a, s)`, 'threading' the otherwise hidden state through the computation. The primitives allow not to bother with that, because most computations can be expressed via composition (in the build-large-things-from-small sense) of primitives. -}
type Stateful s a =
  Stateful (s -> (a, s))


{-| `return val` creates a new (not so) stateful computation which simply evaluates to `val` when run and doesn't access the state in any way. -}
return : a -> Stateful s a
return val =
  Stateful <| \state -> (val, state)


{-| `run state seed` runs `stateful` starting on the initial state `seed`. The computation is evaluated to something of type `a` and also spits out the updated state variable. -}
run : Stateful s a -> s -> (a, s)
run stateful seed =
  case stateful of
    Stateful f -> f seed


{-| `get` is a stateful computation which evaluates to the curren state. This is useful to read out the state without breaking the abstraction boundary of the `Stateful` type. -}
get : Stateful s s
get =
  Stateful <| \state -> (state, state)


{-| `put newState` is a stateful computation which replaces the current state with `newState` and evaluates to nothing interesting. -}
put : s -> Stateful s ()
put newState =
  modify (always newState)


{-| `modify modifier` is a stateful computation which asks `modifier` for a replacement for the current state. It's like a `get` followed by a `put`. -}
modify : (s -> s) -> Stateful s ()
modify modifier =
  Stateful <| \oldState -> ((), modifier oldState)


{-| `map f stateful` applies `f` to the return value of `stateful` upon evaluation and returns that value. -}
map : (a -> b) -> Stateful s a -> Stateful s b
map f stateful =
  Stateful <| \s ->
    let
      (a, s') = run stateful s
    in
      (f a, s')

{-| `andThen` allows to chain computations depending on their return values.
`andThen stateful f` produces a stateful computation which, when run, will ask `f` with the return value of `stateful` for a follow-up computation which will then operate on the updated state.-}
andThen : Stateful s a -> (a -> Stateful s b) -> Stateful s b
andThen stateful f =
  Stateful <| \s ->
    let
      (a, s') = run stateful s
    in
      run (f a) s'


{-| `andMap` can lift a function returned by stateful computation to a function between stateful computations instead. This generalizes `map` to functions with more than one argument:

    (+) `map` get `andMap` get

This will lift `(+)` to work on stateful computations (here it's `get` twice). It's similar to `Signal.~` as `map` is to `Signal.<~`.
I find this more convenient than providing `mapN` functions. -}
andMap : Stateful s (a -> b) -> Stateful s a -> Stateful s b
andMap sf sa =
  Stateful <| \s ->
    let
      (f, s') = run sf s
      (a, s'') = run sa s'
    in
      (f a, s'')


{-| `sequence statefuls` chains the list of stateful computations `statefuls` into a single stateful computation returning all intermediate return values as a list.
It passes the state value through each computation and feeds the follow-up with the modified state.

To illustrate that with the auto-incrementing column ID generator from the README:

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
    -- threeIds = [3, 4, 5]

-}
sequence : List (Stateful s a) -> Stateful s (List a)
sequence statefuls =
  case statefuls of
    [] -> return []
    state :: statefuls' ->
      (::) `map` state `andMap` sequence statefuls'
