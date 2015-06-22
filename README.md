# State [![Build Status](https://travis-ci.org/sgraf812/elm-state.svg)](https://travis-ci.org/sgraf812/elm-state)

A small libraries with primitives for working with stateful computations. This is neat when trying to imitate mutable variables, for example random number seeds or just generating automatically incrementing ids like so:

```
nextId : State Int Int
nextId =
  State.get `State.andThen` \id ->
  State.put (id + 1) `State.andThen` \_ ->
  State.new id

threeIds : List Int
threeIds =
  fst <| State.run
    (State.sequence
      [ nextId
      , nextId
      , nextId
      ])
    3
-- threeIds = [3, 4, 5]
```

The advantage here is that we don't need to manually thread a counter variable.